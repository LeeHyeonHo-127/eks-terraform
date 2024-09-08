terraform {
    required_providers{
        aws = {
            source      = "hashicorp/aws"
            version     = "~> 5.58.0"
        }

        random = {
            source  = "hashicorp/random"
            version = "~> 3.6.0"
        }

        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = "~> 2.31.0"
        }

        helm = {
            source  = "hashicorp/helm"
            version = "~> 2.14.0"
        }
    }

    required_version = "~> 1.8"
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}
