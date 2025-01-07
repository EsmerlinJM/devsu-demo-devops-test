variable "domain_name" {
  default = "esmerlinmieses.com"
  description = "Domain name"
  type = string
}

variable "environment" {
  description = "Environment Variable used as a prefix"
  type = string
  default = "dev"
}