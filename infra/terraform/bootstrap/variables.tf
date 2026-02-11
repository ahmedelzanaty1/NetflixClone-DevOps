variable "aws_region" {
  description = "AWS region for bootstrap resources"
  type        = string
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

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = "terraform-state-locks"
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
