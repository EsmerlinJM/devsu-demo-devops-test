variable "region" {
  description = "AWS region"
  type        = string
  default = "us-east-1"
}

variable "ecr_repository_name" {
  description = "Name of the ECR Repository"
  type        = string
}

variable "ecr_scan_on_push" {
  description = "Scan on push"
  type        = bool
  default = true
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
  ecr_repository = "${local.name}-${var.ecr_repository_name}"  
} 