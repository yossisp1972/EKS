variable "cluster_name" {
	description = "EKS cluster name"
	type        = string
}

variable "cluster_endpoint" {
	description = "EKS cluster endpoint"
	type        = string
}

variable "irsa_arn" {
	description = "Karpenter IRSA role ARN"
	type        = string
}
