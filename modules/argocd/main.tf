

provider "helm" {
	kubernetes {
		host                   = var.cluster_endpoint
		cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
		exec {
			api_version = "client.authentication.k8s.io/v1beta1"
			command     = "aws"
			args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
		}
	}
}

resource "helm_release" "argocd" {
	name       = "argocd"
	namespace  = "argocd"
	repository = "https://argoproj.github.io/argo-helm"
	chart      = "argo-cd"
	version    = "5.51.6"
	create_namespace = true
	set {
		name  = "server.service.type"
		value = "ClusterIP"
	}
	set {
		name  = "server.insecure"
		value = "true"
	}
	set {
		name  = "server.ingress.enabled"
		value = "true"
	}
	set {
		name  = "server.ingress.ingressClassName"
		value = "alb"
	}
	set {
		name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
		value = "internet-facing"
	}
	set {
		name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/listen-ports"
		value = "[{\"HTTP\":80},{\"HTTPS\":443}]"
	}
	set {
		name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/ssl-redirect"
		value = "443"
	}
}
