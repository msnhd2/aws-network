variable "project_name" {
  type   = string
}

variable "region" {
    type = string
    description = "The AWS region to deploy resources in."
    validation {
        condition     = can(regex("^(us|eu|ap|sa|ca)-[a-z]+-[1-9]$", var.region))
        error_message = "The region must be a valid AWS region format, e.g., us-east-1."
    }
    default = "us-east-1"
}

variable "bucket" {
  type    = string
  default = "lab-s3-state-file"
  
}

variable "key" {
  type    = string
  default = "eks/vpc/dev/state"
  
}

variable "vpc_configuration" {
  type = object({
    cidr_block = string
    subnets = list(object({
      name       = string
      cidr_block = string
      public     = bool
    }))
  })
    description = "Configuration for the VPC and its subnets."
}

variable "vpc_additional_cidrs" {
  type = list(string)
  default = []
  description = "Additional CIDR blocks to be associated with the VPC."
}

