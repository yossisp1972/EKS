output "ebs_csi_irsa_arn" {
	value = module.irsa-ebs-csi.iam_role_arn
}

output "karpenter_irsa_arn" {
	value = aws_iam_role.karpenter_controller_role.arn
}

output "lb_controller_irsa_arn" {
	value = aws_iam_role.lb_controller_role.arn
}

output "cluster_name" {
	value = var.cluster_name
}
