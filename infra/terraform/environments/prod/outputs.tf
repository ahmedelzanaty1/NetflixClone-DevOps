output "vpc_id" {
  description = "Production VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs for EKS workloads"
  value       = module.vpc.private_subnets
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "eks_oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  value       = module.eks.oidc_provider_arn
}

output "ecr_repository_urls" {
  description = "Map of ECR repository URLs"
  value = {
    for name, repository in aws_ecr_repository.repositories :
    name => repository.repository_url
  }
}

output "ci_deployer_role_arn" {
  description = "IAM role ARN for CI deployments"
  value       = try(one(aws_iam_role.ci_deployer[*].arn), null)
}
