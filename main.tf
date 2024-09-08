module "skylo_network" {
    source              = "./modules/networking"
    base_cidr_block     = var.base_cidr_block
}

# module "non_vpc_resources" {
#     source              = "./modules/non_vpc_resources"
#     vpc_name            = module.skylo_network.vpc_id
#     domain_name         = var.domain_name
# }

module "eks" {
    source            = "./modules/eks"
    vpc_id            = module.skylo_network.vpc_id
    subnet_ids        = module.skylo_network.eks_subnet_ids
    public_subnet_ids = module.skylo_network.eks_public_subnet_ids

    cluster_addons    = {
        coredns            = {}
        kube-proxy         = {}
        vpc-cni            = {}
        aws-ebs-csi-driver = {}
    }
}

module "rds" {
    source          = "./modules/rds"
    vpc_id                      = module.skylo_network.vpc_id
    password                    = var.db_password
    base_cidr_block             = var.base_cidr_block
    rds_primary_subnet_id       = module.skylo_network.rds_primary_subnet_id
    rds_secondary_subnet_id     = module.skylo_network.rds_secondary_subnet_id

    depends_on = [ module.skylo_network ]
}