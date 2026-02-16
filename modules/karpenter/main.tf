

provider "helm" {
	kubernetes {
		host                   = var.cluster_endpoint
		cluster_ca_certificate = ""
		exec {
			api_version = "client.authentication.k8s.io/v1beta1"
			command     = "aws"
			args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
		}
	}
}

resource "helm_release" "karpenter" {
	name       = "karpenter"
	namespace  = "karpenter"
	repository = "oci://public.ecr.aws/karpenter"
	chart      = "karpenter"
	version    = "v0.33.0"
	create_namespace = true
	set {
		name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
		value = var.irsa_arn
	}
	set {
		name  = "settings.clusterName"
		value = var.cluster_name
	}
	set {
		name  = "settings.clusterEndpoint"
		value = var.cluster_endpoint
	}
	set {
		name  = "settings.interruptionQueueName"
		value = var.cluster_name
	}
}
