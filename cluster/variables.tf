# -----------------------
# Cluster block variables
# -----------------------
variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "cluster_version" {
  description = "EKS cluster version."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "vpc_private_subnets" {
  description = "VPC private subnets."
  type        = list(string)
}

variable "groups_name_prefix" {
  description = "Prefix for EKS cluster user groups."
  type        = string
}

variable "admin_users" {
  description = "List of Kubernetes admins."
  type        = list(string)
}

variable "developer_users" {
  description = "List of Kubernetes developers."
  type        = list(string)
}

variable "asg_instance_types" {
  description = "List of EC2 instance machine types to be used in EKS."
  type        = list(string)
}

variable "autoscaling_minimum_size_by_az" {
  description = "Minimum number of EC2 instances to autoscale our EKS cluster on each AZ."
  type        = number
}

variable "autoscaling_maximum_size_by_az" {
  description = "Maximum number of EC2 instances to autoscale our EKS cluster on each AZ."
  type        = number
}

variable "autoscaling_average_cpu" {
  description = "Average CPU threshold to autoscale EKS EC2 instances."
  type        = number
}

variable "spot_termination_handler_chart_name" {
  description = "EKS Spot termination handler Helm chart name."
  type        = string
}

variable "spot_termination_handler_chart_repo" {
  description = "EKS Spot termination handler Helm repository name."
  type        = string
}

variable "spot_termination_handler_chart_version" {
  description = "EKS Spot termination handler Helm chart version."
  type        = string
}

variable "spot_termination_handler_chart_namespace" {
  description = "Kubernetes namespace to deploy EKS Spot termination handler Helm chart."
  type        = string
}

# -----------------------
# Ingress block variables
# -----------------------
variable "iac_environment_tag" {
  description = "AWS tag to indicate environment name of each infrastructure object."
  type        = string
}

variable "dns_base_domain" {
  description = "DNS Zone name to be used from EKS Ingress."
  type        = string
}

variable "ingress_gateway_chart_name" {
  description = "Ingress Gateway Helm chart name."
  type        = string
}

variable "ingress_gateway_chart_repo" {
  description = "Ingress Gateway Helm repository name."
  type        = string
}

variable "ingress_gateway_chart_version" {
  description = "Ingress Gateway Helm chart version."
  type        = string
}

variable "ingress_gateway_annotations" {
  description = "Ingress Gateway Annotations required for EKS."
  type        = map(string)
}

variable "deployments_subdomains" {
  description = "List of subdomains to be routed to Kubernetes Services."
  type        = list(string)
}
