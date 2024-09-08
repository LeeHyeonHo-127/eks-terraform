variable "region" {
    default = "ap-northeast-2"
}

variable "base_cidr_block" {
    default = "10.0.0.0/16"
}

variable "domain_name" {
    description = "domain name"
    default     = "kosa-skylo.com" 
}

variable "db_password" {
    description = "rds password"
    type        = string
    sensitive   = true
}