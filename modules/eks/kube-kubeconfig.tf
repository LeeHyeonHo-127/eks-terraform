# Manage Kubernetes Config

locals {
  user = "${local.cluster_name}-adm"
}

# local computer에서 작업을 수행하기 위해 null_resource를 많이 사용한다
resource "null_resource" "kubeconfig" {
  depends_on = [
    aws_eks_cluster.eks,
    aws_eks_node_group.eks
  ]

  # Update Kubernetes Config File
  provisioner "local-exec" {
    command = <<EOF
      aws eks update-kubeconfig --name ${local.cluster_name} --user-alias ${local.user} --alias ${local.cluster_name}@${local.user} --region ${var.aws_region}
    EOF
  }

  # 해당 값이 변경되면 다시 실행되게 설정
  triggers = {
    user         = local.user
    cluster_arn  = aws_eks_cluster.eks.arn
    cluster_name = local.cluster_name
  }

  # Remove Kubernetes Config File
  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
      kubectl config delete-user ${self.triggers.user}
      kubectl config delete-cluster ${self.triggers.cluster_arn}
      kubectl config delete-context ${self.triggers.cluster_name}@${self.triggers.user}
    EOF
  }
}

output "update-kubeconfig" {
  # output "kubeconfig-update" {
  value = <<EOF
    aws eks update-kubeconfig --name ${local.cluster_name} --user-alias ${local.user} --alias ${local.cluster_name}@${local.user} --region ${var.aws_region}
    EOF
}

output "delete-kubeconfig" {
  # output "kubeconfig-delete" {
  value = <<EOF
    kubectl config delete-user ${local.user}
    kubectl config delete-cluster ${aws_eks_cluster.eks.arn}
    kubectl config delete-context ${local.cluster_name}@${local.user}
    EOF
}
