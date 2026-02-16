

provider "helm" {
	kubernetes {
		host                   = ""
		cluster_ca_certificate = ""
		exec {
			api_version = "client.authentication.k8s.io/v1beta1"
			command     = "aws"
			args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
		}
	}
}

resource "helm_release" "aws_load_balancer_controller" {
	name       = "aws-load-balancer-controller"
	namespace  = "kube-system"
	repository = "https://aws.github.io/eks-charts"
	chart      = "aws-load-balancer-controller"
	version    = "1.7.1"
	set {
		name  = "clusterName"
		value = var.cluster_name
	}
	set {
		name  = "serviceAccount.create"
		value = "true"
	}
	set {
		name  = "serviceAccount.name"
		value = "aws-load-balancer-controller"
	}
	set {
		name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
		value = var.irsa_arn
	}
}
