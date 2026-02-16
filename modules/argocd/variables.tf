variable "cluster_name" {
	description = "EKS cluster name"
	type        = string
}

variable "cluster_endpoint" {
	description = "EKS cluster endpoint"
	type        = string
}

variable "cluster_certificate_authority_data" {
	description = "EKS cluster CA data"
	type        = string
}
