terraform {
  required_version = "1.10.3"

  required_providers {
    aws = {
      version = ">= 5.82.2"
      source  = "hashicorp/aws"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.17"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.1.3"
    }
  }

  backend "s3" {
    bucket         = "devsu-test-bucket-3322"
    key            = "iac/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "devsu-test-lc"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = var.global_tags
  }
}

module "vpc" {
  source = "./modules/vpc/v1"

  vpc_name             = "${var.cluster_name}-vpc"
  cidr_block           = "10.0.0.0/16"
  nat_gateway          = true
  enable_dns_support   = true
  enable_dns_hostnames = true

  public_subnet_count  = 3
  private_subnet_count = 3
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

module "ecr" {
  source = "./modules/ecr/v1"

  region              = var.region
  ecr_repository_name = var.ecr_repository_name
}

module "eks" {
  source = "./modules/eks/v1"

  region          = var.region
  cluster_name    = var.cluster_name
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id

  managed_node_groups = {
    demo_group = {
      name           = "devsu-ng"
      desired_size   = 1
      min_size       = 1
      max_size       = 2
      instance_types = ["t3.small"]
    }
  }
}