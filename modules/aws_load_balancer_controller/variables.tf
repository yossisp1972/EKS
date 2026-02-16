variable "cluster_name" {
	description = "EKS cluster name"
	type        = string
}

variable "irsa_arn" {
	description = "LB Controller IRSA role ARN"
	type        = string
}
