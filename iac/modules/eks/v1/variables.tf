variable "region" {
  description = "AWS region"
  type        = string
  default = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "public_subnets" {
  description = "Public Subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private Subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "default_ami_type" {
  description = "The type of AMI to use for the node group. Valid values: AL2_x86_64, AL2_x86_64_GPU"
  type        = string
  default     = "AL2_x86_64"
}

variable "default_capacity_type" {
  description = "The capacity type for the node group. Valid values: ON_DEMAND, SPOT"
  type        = string
  default     = "ON_DEMAND"
}

variable "managed_node_groups" {
  description = "Map of maps specifying managed node groups"
  type = map(object({
    name : string
    desired_size : number
    min_size : number
    max_size : number
    instance_types : list(string)
  }))
  default = {}
}

variable "cluster_addons" {
  description = "List of strings specifying cluster addons"
  type        = list(string)
  default     = ["vpc-cni", "kube-proxy", "coredns", "aws-ebs-csi-driver", "metrics-server"]
}

variable "enabled_cluster_log_types" {
  description = "List of strings specifying cluster log types"
  type        = list(string)
  default     = ["audit", "api", "authenticator"]
}

variable "environment" {
  description = "Environment Variable used as a prefix"
  type = string
  default = "dev"
}

locals {
  environment = var.environment
  name = "${var.environment}"
  common_tags = {
    environment = local.environment
  }
  eks_cluster_name = "${local.name}-${var.cluster_name}"  
}

variable "domain_name" {
  default = "esmerlinmieses.com"
  description = "Domain name"
  type = string
}