
variable "cluster_name" {
	description = "EKS cluster name"
	type        = string
}

variable "oidc_provider" {
	description = "OIDC provider URL"
	type        = string
}

variable "oidc_provider_arn" {
	description = "OIDC provider ARN"
	type        = string
}

# EBS CSI IRSA
data "aws_iam_policy" "ebs_csi_policy" {
	arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
	source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
	version = "5.39.0"

	create_role                   = true
	role_name                     = "AmazonEKSTFEBSCSIRole-${var.cluster_name}"
	provider_url                  = var.oidc_provider
	role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
	oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

# Karpenter Controller Policy
resource "aws_iam_policy" "karpenter_controller_policy" {
	name        = "KarpenterControllerPolicy-${var.cluster_name}"
	description = "IAM policy for Karpenter controller"
	policy = jsonencode({
		Version = "2012-10-17"
		Statement = [
			{
				Effect = "Allow"
				Action = [
					"ec2:CreateFleet",
					"ec2:CreateLaunchTemplate",
					"ec2:CreateTags",
					"ec2:DescribeAvailabilityZones",
					"ec2:DescribeImages",
					"ec2:DescribeInstances",
					"ec2:DescribeInstanceTypeOfferings",
					"ec2:DescribeInstanceTypes",
					"ec2:DescribeLaunchTemplates",
					"ec2:DescribeSecurityGroups",
					"ec2:DescribeSpotPriceHistory",
					"ec2:DescribeSubnets",
					"ec2:DeleteLaunchTemplate",
					"ec2:RunInstances",
					"ec2:TerminateInstances"
				]
				Resource = "*"
			},
			{
				Effect = "Allow"
				Action = [
					"iam:PassRole",
					"iam:GetInstanceProfile",
					"iam:CreateInstanceProfile",
					"iam:TagInstanceProfile",
					"iam:AddRoleToInstanceProfile",
					"iam:RemoveRoleFromInstanceProfile",
					"iam:DeleteInstanceProfile"
				]
				Resource = "*"
			},
			{
				Effect = "Allow"
				Action = ["pricing:GetProducts"]
				Resource = "*"
			},
			{
				Effect = "Allow"
				Action = ["eks:DescribeCluster"]
				Resource = "arn:aws:eks:*:*:cluster/${var.cluster_name}"
			},
			{
				Effect = "Allow"
				Action = [
					"sqs:DeleteMessage",
					"sqs:GetQueueAttributes",
					"sqs:GetQueueUrl",
					"sqs:ReceiveMessage"
				]
				Resource = "*"
			}
		]
	})
}

# IRSA for Karpenter
module "irsa-karpenter" {
	source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
	version = "5.39.0"

	create_role      = true
	role_name        = "KarpenterControllerRole-${var.cluster_name}"
	provider_url     = var.oidc_provider
	role_policy_arns = [
		aws_iam_policy.karpenter_controller_policy.arn,
		"arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
	]
	oidc_fully_qualified_subjects = ["system:serviceaccount:karpenter:karpenter"]
}

# IRSA for AWS Load Balancer Controller
module "irsa-aws-load-balancer-controller" {
	source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
	version = "5.39.0"

	role_name = "AmazonEKSLoadBalancerControllerRole-${var.cluster_name}"
	attach_load_balancer_controller_policy = true
	oidc_providers = {
		main = {
			provider_arn               = var.oidc_provider_arn
			namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
		}
	}
}

# IAM Role for Karpenter nodes
resource "aws_iam_role" "karpenter_node_role" {
	name = "KarpenterNodeRole-${var.cluster_name}"
	assume_role_policy = jsonencode({
		Version = "2012-10-17"
		Statement = [
			{
				Action = "sts:AssumeRole"
				Effect = "Allow"
				Principal = {
					Service = "ec2.amazonaws.com"
				}
			}
		]
	})
}

resource "aws_iam_role_policy_attachment" "karpenter_node_role_policies" {
	for_each = toset([
		"arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
		"arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
		"arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
		"arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
	])
	role       = aws_iam_role.karpenter_node_role.name
	policy_arn = each.value
}

resource "aws_iam_instance_profile" "karpenter_node_instance_profile" {
	name = "KarpenterNodeInstanceProfile-${var.cluster_name}"
	role = aws_iam_role.karpenter_node_role.name
}

output "ebs_csi_irsa_arn" {
	value = module.irsa-ebs-csi.iam_role_arn
}

output "karpenter_irsa_arn" {
	value = module.irsa-karpenter.iam_role_arn
}

output "lb_controller_irsa_arn" {
	value = module.irsa-aws-load-balancer-controller.iam_role_arn
}
