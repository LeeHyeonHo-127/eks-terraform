# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0
locals {
  rds_name        = "rdsname${random_string.suffix.result}"
  rds_identifier  = "rdsidentifier${random_string.suffix.result}" 
}

# random 이름 생성 리소스
resource "random_string" "suffix" {
  length = 6

  lower   = true
  upper   = false
  numeric = true
  special = false
}

terraform {
    required_version = ">= 0.12"
}

# provider "aws" {
#     region = var.aws_region
# }

# RDS 생성 Resource
resource "aws_db_instance" "default" {
    depends_on                = [aws_security_group.default]
    # identifier              = var.identifier
    identifier                = local.rds_identifier
    allocated_storage         = var.storage
    engine                    = var.engine
    engine_version            = var.engine_version[var.engine]
    instance_class            = var.instance_class
    # db_name                 = var.db_name
    db_name                   = local.rds_name
    username                  = var.username
    password                  = var.password
    vpc_security_group_ids    = [aws_security_group.default.id]
    db_subnet_group_name      = aws_db_subnet_group.default.id
    final_snapshot_identifier = false
    skip_final_snapshot       = true
}

# RDS Subnet Group 생성 리소스
resource "aws_db_subnet_group" "default" {
    description     = "Our main group of subnets"
    name            = local.subnet_group_name
    subnet_ids      = [var.rds_primary_subnet_id, var.rds_secondary_subnet_id]
}


locals {
  subnet_group_name     = "main_subnet_group-${random_string.suffix.result}"
}