variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Target AWS region."
}

variable "cluster_name" {
  type        = string
  default     = "devsu-test-cluster"
  description = "Name of the EKS cluster."
}

variable "ecr_repository_name" {
  type        = string
  default     = "devsu-test-repository"
  description = "Name of the ECR Repository."
}

variable "aws_account_number" {
  type        = number
  description = "AWS account number used for deployment."
}

variable "global_tags" {
  type = map(string)
  default = {
    "ManagedBy"   = "Terraform"
    "Environment" = "prod"
  }
}