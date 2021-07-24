# -----------------------
# Network block variables
# -----------------------
variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "iac_environment_tag" {
  description = "AWS tag to indicate environment name of each infrastructure object."
  type        = string
}

variable "name_prefix" {
  description = "Prefix to be used on each infrastructure object Name created in AWS."
  type        = string
}

variable "main_network_block" {
  description = "Base CIDR block to be used in our VPC."
  type        = string
}

variable "subnet_prefix_extension" {
  description = "CIDR block bits extension to calculate CIDR blocks of each subnetwork."
  type        = number
}

variable "zone_offset" {
  description = "CIDR block bits extension offset to calculate Public subnets, avoiding collisions with Private subnets."
  type        = number
}
