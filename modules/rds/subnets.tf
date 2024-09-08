# # Copyright (c) HashiCorp, Inc.
# # SPDX-License-Identifier: MPL-2.0

# resource "aws_subnet" "subnet_1" {
#     vpc_id              = var.vpc_id
#     cidr_block          = cidrsubnet(var.base_cidr_block, 2, 2)
#     availability_zone   = var.az_1

#     tags = {
#         Name = "main_subnet1"
#     } 
# }

# resource "aws_subnet" "subnet_2" {
#     vpc_id              = var.vpc_id
#     cidr_block          = cidrsubnet(var.base_cidr_block, 2, 3)
#     availability_zone   = var.az_2 

#     tags = {
#         Name = "main_subnet2"
#     }

# }