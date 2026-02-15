output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
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

output "ebs_csi_irsa_arn" {
  value = module.iam.ebs_csi_irsa_arn
}

output "karpenter_irsa_arn" {
  value = module.iam.karpenter_irsa_arn
}

output "lb_controller_irsa_arn" {
  value = module.iam.lb_controller_irsa_arn
}
