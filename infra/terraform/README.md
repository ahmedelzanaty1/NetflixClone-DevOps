# Production Terraform Infrastructure

This directory contains production-ready AWS infrastructure for the Netflix Clone platform.

## What is provisioned

- **Remote Terraform state bootstrap**: S3 (versioning + encryption + public access block) and DynamoDB lock table with PITR.
- **VPC**: multi-AZ VPC with public/private subnets, NAT gateways per AZ, DNS hostnames/support enabled.
- **EKS**: managed Kubernetes cluster and managed node group.
- **ECR**: immutable, scan-on-push repositories with lifecycle policies.
- **IAM (least privilege)**: optional CI deployer role scoped to ECR push/pull and EKS cluster describe.

## Layout

- `bootstrap/`: one-time stack to create remote state resources.
- `environments/prod/`: production infrastructure stack that uses remote backend.

## Prerequisites

- Terraform `>= 1.6`
- AWS credentials with sufficient privileges

## 1) Bootstrap remote state resources

```bash
cd infra/terraform/bootstrap
terraform init
terraform apply \
  -var="aws_region=us-east-1" \
  -var="state_bucket_name=<globally-unique-bucket-name>" \
  -var="dynamodb_table_name=terraform-state-locks"
```

## 2) Configure backend for prod stack

```bash
cd ../environments/prod
cp backend.hcl.example backend.hcl
# edit backend.hcl values
terraform init -backend-config=backend.hcl
```

## 3) Configure variables and apply prod stack

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars values
terraform plan
terraform apply
```

## Security notes

- The CI role is only created when `ci_principal_arns` is non-empty.
- CI permissions are scoped to created ECR repositories and `eks:DescribeCluster` on this cluster.
- ECR repositories are immutable and scanned on image push.
