

data "aws_availability_zones" "available" {
	filter {
		name   = "opt-in-status"
		values = ["opt-in-not-required"]
	}
}


module "vpc" {
	source  = "terraform-aws-modules/vpc/aws"
	version = "5.8.1"

	name = "education-vpc"
	cidr = "10.0.0.0/16"
	azs  = slice(data.aws_availability_zones.available.names, 0, 3)

	private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
	public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

	enable_nat_gateway   = true
	single_nat_gateway   = true
	enable_dns_hostnames = true
	enable_dns_support   = true

	public_subnet_tags = {
		"kubernetes.io/role/elb" = 1
	}
	private_subnet_tags = {
		"kubernetes.io/role/internal-elb" = 1
		"karpenter.sh/discovery"          = var.cluster_name
	}
	tags = {
		"karpenter.sh/discovery" = var.cluster_name
	}
}

# VPC Endpoints for AWS services
resource "aws_vpc_endpoint" "s3" {
	vpc_id         = module.vpc.vpc_id
	service_name   = "com.amazonaws.${var.region}.s3"
	route_table_ids = module.vpc.private_route_table_ids
	tags = { Name = "s3-endpoint" }
}

resource "aws_security_group" "vpc_endpoints" {
	name        = "vpc-endpoints-sg"
	description = "Security group for VPC endpoints"
	vpc_id      = module.vpc.vpc_id
	ingress {
		description = "HTTPS from VPC"
		from_port   = 443
		to_port     = 443
		protocol    = "tcp"
		cidr_blocks = [module.vpc.vpc_cidr_block]
	}
	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	tags = { Name = "vpc-endpoints-sg" }
}

resource "aws_vpc_endpoint" "ecr_api" {
	vpc_id              = module.vpc.vpc_id
	service_name        = "com.amazonaws.${var.region}.ecr.api"
	vpc_endpoint_type   = "Interface"
	subnet_ids          = module.vpc.private_subnets
	security_group_ids  = [aws_security_group.vpc_endpoints.id]
	private_dns_enabled = true
	tags = { Name = "ecr-api-endpoint" }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
	vpc_id              = module.vpc.vpc_id
	service_name        = "com.amazonaws.${var.region}.ecr.dkr"
	vpc_endpoint_type   = "Interface"
	subnet_ids          = module.vpc.private_subnets
	security_group_ids  = [aws_security_group.vpc_endpoints.id]
	private_dns_enabled = true
	tags = { Name = "ecr-dkr-endpoint" }
}

resource "aws_vpc_endpoint" "ec2" {
	vpc_id              = module.vpc.vpc_id
	service_name        = "com.amazonaws.${var.region}.ec2"
	vpc_endpoint_type   = "Interface"
	subnet_ids          = module.vpc.private_subnets
	security_group_ids  = [aws_security_group.vpc_endpoints.id]
	private_dns_enabled = true
	tags = { Name = "ec2-endpoint" }
}

resource "aws_vpc_endpoint" "sts" {
	vpc_id              = module.vpc.vpc_id
	service_name        = "com.amazonaws.${var.region}.sts"
	vpc_endpoint_type   = "Interface"
	subnet_ids          = module.vpc.private_subnets
	security_group_ids  = [aws_security_group.vpc_endpoints.id]
	private_dns_enabled = true
	tags = { Name = "sts-endpoint" }
}

