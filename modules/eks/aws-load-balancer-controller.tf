# Addon - AWS Load Balancer Controller
# https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/aws-load-balancer-controller.html

module "aws_load_balancer_controller_irsa_role" {
  # depends_on = [
  #   module.eks
  # ]

  depends_on = [ 
    null_resource.kubeconfig, 
    aws_eks_node_group.eks
   ]


  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = "aws-load-balancer-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      # provider_arn               = aws_eks_cluster.eks.oidc_provider_arn
      provider_arn               = aws_iam_openid_connect_provider.oidc_provider.arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "kubernetes_service_account" "aws-load-balancer-controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = module.aws_load_balancer_controller_irsa_role.iam_role_arn
    }
  }
  depends_on = [ 
    null_resource.kubeconfig,
    aws_eks_node_group.eks
    ]
}

resource "helm_release" "aws-load-balancer-controller" {


  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = ">= 1.8.0"

  values = [
    templatefile("${path.module}/aws-load-balancer-controller.yml", {
      clusterName = local.cluster_name,
      region      = var.aws_region,
      vpcId       = var.vpc_id
      }
    )
  ]
  
  depends_on = [
    kubernetes_service_account.aws-load-balancer-controller,
    aws_eks_cluster.eks,
    aws_eks_node_group.eks
  ]
}
