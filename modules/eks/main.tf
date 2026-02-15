
variable "cluster_name" {
	description = "EKS cluster name"
	type        = string
}

variable "private_subnets" {
	description = "Private subnet IDs"
	type        = list(string)
}

variable "vpc_id" {
	description = "VPC ID"
	type        = string
}

module "eks" {
	source  = "terraform-aws-modules/eks/aws"
	version = "20.8.5"

	cluster_name    = var.cluster_name
	cluster_version = "1.29"

	cluster_endpoint_public_access           = true
	enable_cluster_creator_admin_permissions = true

	vpc_id     = var.vpc_id
	subnet_ids = var.private_subnets

	eks_managed_node_group_defaults = {
		ami_type = "AL2_x86_64"
	}

	eks_managed_node_groups = {
		one = {
			name = "node-group-1"
			instance_types = ["t3.small"]
			min_size     = 1
			max_size     = 3
			desired_size = 2
		}
	}
}

# Tag the EKS cluster security group for Karpenter discovery
resource "aws_ec2_tag" "cluster_security_group" {
	resource_id = module.eks.cluster_security_group_id
	key         = "karpenter.sh/discovery"
	value       = var.cluster_name
}

resource "aws_ec2_tag" "node_security_group" {
	resource_id = module.eks.node_security_group_id
	key         = "karpenter.sh/discovery"
	value       = var.cluster_name
}

output "cluster_name" {
	value = module.eks.cluster_name
}

output "cluster_endpoint" {
	value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
	value = module.eks.cluster_certificate_authority_data
}

output "oidc_provider" {
	value = module.eks.oidc_provider
}

output "oidc_provider_arn" {
	value = module.eks.oidc_provider_arn
}
