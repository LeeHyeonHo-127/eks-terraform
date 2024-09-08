# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0



variable "aws_region" {
    default = "ap-northeast-2"
}

variable "base_cidr_block" {    
    description = "vpc cidr_block"
}

variable "identifier" {
    default     = "mydb-rds"
    description = "DB의 이름"
}

variable storage {
    default     = "10"
    description = "DB 스토리지 크기(GB)"
}

variable engine {
    default     = "mariadb"
    description = "DB Engine type, mariadb"
}

variable "engine_version" {
    description = "DB Engine version"
    default = {
        mariadb = "10.11"
    }
}

variable "instance_class" {
    default     = "db.t4g.micro"
    description = "Instance Class"
}

variable "db_name" {
    default     = "mydb"
    description = "db name"
}

variable "username" {
    default     = "myuser"
    description = "User name"
}

variable "password" {
    description = "환경변수로 Password 전달하기"
}

variable "az_numbers" {
  default = {
    a = 0
    b = 1
    c = 2
    d = 3
    e = 4
    f = 5
    g = 6
    h = 7
    i = 8
    j = 9
    k = 10
    l = 11
    m = 12
    n = 13
  }
}