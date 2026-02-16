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
