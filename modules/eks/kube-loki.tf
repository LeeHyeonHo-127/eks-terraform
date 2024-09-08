# module "aws_s3_loki_stack" {
#   source  = "terraform-iaac/loki-stack/kubernetes"

#   # In case if IRSA is enabled. IRSA must have S3 RW Policy access.
#   # Otherwise, your instance must have S3 RW Policy attached.
#   loki_service_account_annotations = {
#     "eks.amazonaws.com/role-arn" = "arn:aws:iam::058264317535:role/test-loki"
#   }

#   provider_type = "aws"
#   s3_name       = "s3-bucket-loki-logs"
#   s3_region     = "ap-northeast-2"
# }