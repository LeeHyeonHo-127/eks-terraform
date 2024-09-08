# EKS 클러스터 리소스
#  * EKS 서비스가 다른 AWS 서비스를 관리할 수 있도록 하는 IAM 역할
#  * EKS 클러스터와 네트워킹 트래픽을 허용하는 EC2 보안 그룹
#  * EKS 클러스터
#  * EKS 클러스터의 관리자 권한을 부여하기 위한 액세스 엔트리
#  * EKS 클러스터에 들어갈 노드 그룹


# 생성 순서 (추후 수정)
# 1. kube-ingress, hpa, helms 주석 처리 후 생성
# 2. kube-ingress, hpa 생성
# 3. helm 생성

################################################################################
# 데이터 소스
################################################################################

data "aws_eks_addon_version" "this" {
    for_each            = { for k, v in var.cluster_addons : k => v if local.create}

    addon_name          = try(each.value.name, each.key)
    kubernetes_version  = coalesce(var.cluster_version, aws_eks_cluster.eks.version) 
}

# 특정 태그를 가진 서브넷의 세부 정보를 가져옵니다.
data "aws_subnets" "eks_subnets_pri" {
  filter {
    name = "tag:Name"
    values = ["private-subnet-1"]
  }
}

# 사용 가능한 AWS 가용 영역에 대한 세부 정보를 가져옵니다.
data "aws_availability_zones" "available" {
  state = "available"
}

# 현재 IAM 사용자의 정보를 가져옵니다.
data "aws_caller_identity" "current" {}

# # "KOSA-GROUP"에 속한 모든 사용자 정보를 가져옵니다.
# data "aws_iam_group" "kosa_group" {
#   group_name = var.iam_group_name
# }

# data "aws_iam_policy" "ebs_csi" {
#   name = "AmazonEBSCSIDriverPolicy"
# }

data "aws_partition" "current" {}

# Thumbprint of Root CA for EKS OIDC
data "tls_certificate" "eks_tls_certificate" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
  # url = data.terraform_remote_state.eks.outputs.cluster_oidc_issuer_url
}

################################################################################
# Random 리소스
################################################################################

# 로컬 변수를 정의합니다.
locals {
  cluster_name     = "eks-cluster-${random_string.suffix.result}"
  efs_name         = "eks-efs-${random_string.suffix.result}"
  node_group_name  = "node-group-${random_string.suffix.result}"
  create           = var.create 
}

# 리소스 명명을 위한 랜덤 문자열을 생성합니다.
resource "random_string" "suffix" {
  length = 8

  lower   = true
  upper   = false
  numeric = true
  special = false
}

################################################################################
# 클러스터
################################################################################

# 로컬 변수를 정의합니다.
locals {
  eks_cluster_exists = length([for role in data.aws_iam_roles.all_roles.names : role if role == "eks-iam-role-${random_string.suffix.result}"]) > 0
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url                 = aws_eks_cluster.eks.identity[0].oidc[0].issuer
  client_id_list      = ["sts.${data.aws_partition.current.dns_suffix}"]
  thumbprint_list = [data.tls_certificate.eks_tls_certificate.certificates[0].sha1_fingerprint]

  tags = {
    Name = "${aws_eks_cluster.eks.name}-irsa"
  }

  depends_on = [ 
    aws_eks_node_group.eks
   ]
}

################################################################################
# Cluster
################################################################################

resource "aws_iam_role" "eks-cluster" {
  name = "eks-iam-role-${random_string.suffix.result}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-cluster.name
}


# EKS 클러스터를 생성합니다.
resource "aws_eks_cluster" "eks" {
    name        = local.cluster_name
    role_arn    = aws_iam_role.eks-cluster.arn
    version     = var.cluster_version

  vpc_config {
    security_group_ids             = [aws_security_group.eks-cluster.id]
    subnet_ids                     = var.subnet_ids
    endpoint_private_access        = true   # 프라이빗 액세스 활성화
    endpoint_public_access         = true  # 퍼블릭 액세스 활성화 (필요에 따라 조정)
  }

  access_config {
    authentication_mode                         = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    data.aws_subnets.eks_subnets_pri, # VPC 먼저 생성되어야 함
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSVPCResourceController,
  ]
}

################################################################################
# 클러스터 보안 그룹
# https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html 을 기준으로 작성되었습니다.
################################################################################

resource "aws_security_group" "eks-cluster" {
  name        = "terraform-eks-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-eks"
  }
}


################################################################################
# 접근 항목
################################################################################

# # 로컬 변수를 정의합니다.
# locals {
#   # 현재 사용자를 제외한 "KOSA-GROUP" 내의 모든 사용자에 대한 리스트를 만듭니다.
#   user_names = [for user in data.aws_iam_group.kosa_group.users : user.user_name if user.user_name != data.aws_caller_identity.current.user_id]
# }

# # 각 사용자에 대한 IAM 사용자 데이터를 가져옵니다.
# data "aws_iam_user" "users" {
#   for_each  = toset(local.user_names)
#   user_name = each.key
# }

# # 각 사용자에 대해 Access Entry를 생성합니다.
# resource "aws_eks_access_entry" "user_entries" {
#   for_each = data.aws_iam_user.users

#   cluster_name  = aws_eks_cluster.eks.name
#   principal_arn = each.value.arn
#   type          = "STANDARD"
# }


# # 각 사용자에 대해 Access Policy Association을 생성합니다.
# resource "aws_eks_access_policy_association" "user_policies" {
#   for_each = data.aws_iam_user.users

#   cluster_name  = aws_eks_cluster.eks.name
#   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
#   principal_arn = each.value.arn

#   access_scope {
#     type = "cluster"
#   }
# }

################################################################################
# Node Group
################################################################################


resource "aws_iam_role" "eks-node" {
  name = "eks-nodegroup-iam-role-${random_string.suffix.result}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-node.name
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-node.name
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-node.name
}

resource "aws_eks_node_group" "eks" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = local.node_group_name
  node_role_arn   = aws_iam_role.eks-node.arn
  subnet_ids      = var.subnet_ids
  ami_type        = "AL2_x86_64"
  # instance_types  =  

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}

################################################################################
# EKS Addons
################################################################################

resource "aws_eks_addon" "this" {
  # Not supported on outposts
  for_each = { for k, v in var.cluster_addons : k => v if !try(v.before_compute, false) && local.create }

  cluster_name = aws_eks_cluster.eks.name
  addon_name   = try(each.value.name, each.key)

  addon_version               = coalesce(try(each.value.addon_version, null), data.aws_eks_addon_version.this[each.key].version)
  configuration_values        = try(each.value.configuration_values, null)
  preserve                    = try(each.value.preserve, true)
  resolve_conflicts_on_create = try(each.value.resolve_conflicts_on_create, "OVERWRITE")
  resolve_conflicts_on_update = try(each.value.resolve_conflicts_on_update, "OVERWRITE")
  service_account_role_arn    = try(each.value.service_account_role_arn, null)

  timeouts {
    create = try(each.value.timeouts.create, var.cluster_addons_timeouts.create, null)
    update = try(each.value.timeouts.update, var.cluster_addons_timeouts.update, null)
    delete = try(each.value.timeouts.delete, var.cluster_addons_timeouts.delete, null)
  }

  depends_on = [
    aws_eks_cluster.eks,
    aws_eks_node_group.eks

  ]

  tags = merge(var.tags, try(each.value.tags, {}))
}

resource "aws_eks_addon" "before_compute" {
  # Not supported on outposts
  for_each = { for k, v in var.cluster_addons : k => v if try(v.before_compute, false) && local.create}

  cluster_name = aws_eks_cluster.eks.name
  addon_name   = try(each.value.name, each.key)

  addon_version               = coalesce(try(each.value.addon_version, null), data.aws_eks_addon_version.this[each.key].version)
  configuration_values        = try(each.value.configuration_values, null)
  preserve                    = try(each.value.preserve, true)
  resolve_conflicts_on_create = try(each.value.resolve_conflicts_on_create, "OVERWRITE")
  resolve_conflicts_on_update = try(each.value.resolve_conflicts_on_update, "OVERWRITE")
  service_account_role_arn    = try(each.value.service_account_role_arn, null)

  timeouts {
    create = try(each.value.timeouts.create, var.cluster_addons_timeouts.create, null)
    update = try(each.value.timeouts.update, var.cluster_addons_timeouts.update, null)
    delete = try(each.value.timeouts.delete, var.cluster_addons_timeouts.delete, null)
  }

  tags = merge(var.tags, try(each.value.tags, {}))

  depends_on = [
    aws_eks_cluster.eks,
    aws_eks_node_group.eks
  ]
}