variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "skylo-bucket-0729"  # 기본값으로 빈 문자열 설정
}

# variable "index_document" {
#   description = "The index document for the S3 bucket"
#   type        = string
# }

# variable "error_document" {
#   description = "The error document for the S3 bucket"
#   type        = string
# }

variable "vpc_name" {}

variable "domain_name" {
  description = "구입한 도매인"
}
