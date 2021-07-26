# -----------------------
# Network block variables
# -----------------------
variable "cidr_block" {
  description = "CIDR block for the EKS cluster."
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "az" {
  description = "Availability zone for the EKS cluster."
  type        = list(string)
}

variable "private_network_config" {
  type = map(object({
    cidr_block               = string
    associated_public_subnet = string
  }))

  default = {
    "private-devops-1" = {
      cidr_block               = "10.0.0.0/23"
      associated_public_subnet = "public-devops-1"
    },
    "private-devops-2" = {
      cidr_block               = "10.0.2.0/23"
      associated_public_subnet = "public-devops-2"
    }
  }
}

locals {
  private_nested_config = flatten([
    for name, config in var.private_network_config : [
      {
        name                     = name
        cidr_block               = config.cidr_block
        associated_public_subnet = config.associated_public_subnet
      }
    ]
  ])
}

variable "public_network_config" {
  type = map(object({
    cidr_block = string
  }))

  default = {
    "public-devops-1" = {
      cidr_block = "10.0.8.0/23"
    },
    "public-devops-2" = {
      cidr_block = "10.0.10.0/23"
    }
  }
}

locals {
  public_nested_config = flatten([
    for name, config in var.public_network_config : [
      {
        name       = name
        cidr_block = config.cidr_block
      }
    ]
  ])
}

# -----------------------
# Cluster block variables
# -----------------------
variable "eks_cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "eks_cluster_version" {
  description = "EKS cluster version."
  type        = string
}

variable "authorized_source_ranges" {
  type        = string
  description = "Addresses or CIDR blocks which are allowed to connect. The default behavior is to allow anyone (0.0.0.0/0) access. You should restrict access to external IPs that need to access the cluster."
  default     = "0.0.0.0/0"
}

variable "private_instance_types" {
  description = "The list of instance types to use for the private nodes."
  type        = list(string)
}

variable "private_desired_size" {
  description = "The number of nodes to run in the cluster."
  type        = number
}

variable "private_min_size" {
  description = "The minimum number of nodes to run in the cluster."
  type        = number
}

variable "private_max_size" {
  description = "The maximum number of nodes to run in the cluster."
  type        = number
}

variable "public_desired_size" {
  description = "The number of nodes to run in the cluster."
  type        = number
}

variable "public_min_size" {
  description = "The minimum number of nodes to run in the cluster."
  type        = number
}

variable "public_max_size" {
  description = "The maximum number of nodes to run in the cluster."
  type        = number
}

variable "public_instance_types" {
  description = "The list of instance types to use for the public nodes."
  type        = list(string)
}

