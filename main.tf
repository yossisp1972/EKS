module "vpc" {
  source = "./modules/vpc"
}

module "eks" {
  source = "./modules/eks"
  vpc_id = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  public_subnets = module.vpc.public_subnets
  cluster_name = module.vpc.cluster_name
}

module "iam" {
  source = "./modules/iam"
  cluster_name = module.eks.cluster_name
  oidc_provider = module.eks.oidc_provider
  oidc_provider_arn = module.eks.oidc_provider_arn
}

module "argocd" {
  source = "./modules/argocd"
  cluster_name = module.eks.cluster_name
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  depends_on = [module.eks, module.iam]
}

module "karpenter" {
  source = "./modules/karpenter"
  cluster_name = module.eks.cluster_name
  cluster_endpoint = module.eks.cluster_endpoint
  irsa_arn = module.iam.karpenter_irsa_arn
  depends_on = [module.eks, module.iam]
}

module "aws_load_balancer_controller" {
  source = "./modules/aws_load_balancer_controller"
  cluster_name = module.eks.cluster_name
  irsa_arn = module.iam.lb_controller_irsa_arn
  depends_on = [module.eks, module.iam]
}
