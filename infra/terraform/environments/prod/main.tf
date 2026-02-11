locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = merge(
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "${local.name_prefix}-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  enable_dns_support   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = local.common_tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.2"

  cluster_name    = "${local.name_prefix}-eks"
  cluster_version = var.cluster_version

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    instance_types = var.node_group_instance_types

    iam_role_additional_policies = {
      ecr_read_only = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      cw_agent      = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    }
  }

  eks_managed_node_groups = {
    general = {
      name = "general"

      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size

      capacity_type = "ON_DEMAND"
      labels = {
        workload = "general"
      }
      tags = {
        Name = "${local.name_prefix}-general"
      }
    }
  }

  tags = local.common_tags
}

resource "aws_ecr_repository" "repositories" {
  for_each = toset(var.ecr_repository_names)

  name                 = each.value
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = local.common_tags
}

resource "aws_ecr_lifecycle_policy" "repositories" {
  for_each = aws_ecr_repository.repositories

  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "ci_assume_role" {
  statement {
    sid    = "AllowAssumeRoleFromTrustedPrincipals"
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.ci_principal_arns
    }
  }
}

resource "aws_iam_role" "ci_deployer" {
  count = length(var.ci_principal_arns) > 0 ? 1 : 0

  name               = "${local.name_prefix}-ci-deployer"
  assume_role_policy = data.aws_iam_policy_document.ci_assume_role.json
  description        = "Least-privilege role for CI to push images and deploy to EKS"

  tags = local.common_tags
}

data "aws_iam_policy_document" "ci_permissions" {
  statement {
    sid    = "EcrAuthorizationToken"
    effect = "Allow"

    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "EcrPushPullScoped"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    resources = [for repository in aws_ecr_repository.repositories : repository.arn]
  }

  statement {
    sid    = "DescribeCluster"
    effect = "Allow"

    actions   = ["eks:DescribeCluster"]
    resources = [module.eks.cluster_arn]
  }
}

resource "aws_iam_policy" "ci_permissions" {
  count = length(var.ci_principal_arns) > 0 ? 1 : 0

  name        = "${local.name_prefix}-ci-deployer-policy"
  description = "Least-privilege permissions for CI deployments"
  policy      = data.aws_iam_policy_document.ci_permissions.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ci_permissions" {
  count = length(var.ci_principal_arns) > 0 ? 1 : 0

  role       = aws_iam_role.ci_deployer[0].name
  policy_arn = aws_iam_policy.ci_permissions[0].arn
}
