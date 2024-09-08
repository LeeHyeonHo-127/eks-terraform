# # StorageClass for EBS
# resource "kubernetes_storage_class" "ebs-gp3-sc" {
#   metadata {
#     name = "ebs-gp3-sc"
#   }
#   storage_provisioner = "ebs.csi.aws.com"
#   reclaim_policy      = "Delete"
#   volume_binding_mode = "WaitForFirstConsumer"
#   parameters = {
#     "csi.storage.k8s.io/fstype" = "ext4"
#     type                        = "gp3"
#   }
# }
