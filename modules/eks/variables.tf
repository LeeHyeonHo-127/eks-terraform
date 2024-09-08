# IAM 역할이 존재하는지 확인
data "aws_iam_roles" "all_roles" {}


variable "aws_region" {
  description = "The AWS region to deploy Cluster in"
  default = "ap-northeast-2"
}

variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "The ID of the subnets"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "ALB 가 Private Subnet과 연결하기위해서 필요한 서브넷"
  type        = list(string)
}


variable "cluster_addons" {
  description = "Map of cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with `name`"
  type        = any
  default     = {}
}

variable "create" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.27`)"
  type        = string
  default     = "1.30"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "cluster_addons_timeouts" {
  description = "Create, update, and delete timeout configurations for the cluster addons"
  type        = map(string)
  default     = {}
}

variable "team" {
    type        = string
    default     = "skylo"
}


locals {
  name_prefix = "${var.team}"
  common_tags = {
    group = local.name_prefix
  }
}

variable "iam_group_name" {
  description = "Name of the IAM group to grant EKS access"
  type        = string
  default     = "KOSA-GROUP"
}

variable "authentication_mode" {
  description = "The authentication mode for the cluster"
  type        = string
  default     = "API_AND_CONFIG_MAP"  
}