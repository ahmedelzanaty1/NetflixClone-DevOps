variable "aws_region" {
  description = "AWS region for the production environment"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project identifier used in naming"
  type        = string
  default     = "netflix-clone"
}

variable "environment" {
  description = "Environment identifier"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs for worker nodes"
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs for load balancers/NAT"
  type        = list(string)
  default     = ["10.20.101.0/24", "10.20.102.0/24", "10.20.103.0/24"]
}

variable "cluster_version" {
  description = "EKS control plane version"
  type        = string
  default     = "1.30"
}

variable "node_group_instance_types" {
  description = "EC2 instance types used by managed node groups"
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_group_min_size" {
  description = "Minimum worker node count"
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "Maximum worker node count"
  type        = number
  default     = 6
}

variable "node_group_desired_size" {
  description = "Desired worker node count"
  type        = number
  default     = 3
}

variable "ecr_repository_names" {
  description = "ECR repositories to create"
  type        = list(string)
  default     = ["netflix-clone-client", "netflix-clone-server"]
}

variable "ci_principal_arns" {
  description = "IAM principal ARNs allowed to assume the CI role"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
