output "terraform_state_bucket_name" {
  value       = aws_s3_bucket.terraform_state.id
  description = "S3 bucket name for remote Terraform state"
}

output "terraform_lock_table_name" {
  value       = aws_dynamodb_table.terraform_lock.name
  description = "DynamoDB table name for Terraform state locking"
}
