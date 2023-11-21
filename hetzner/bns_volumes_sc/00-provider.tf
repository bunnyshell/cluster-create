terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.12.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">=1.13.1"
    }
  }
}

provider "kubectl" {
  host                   = var.host
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  client_key             = base64decode(var.client_key)
  client_certificate     = base64decode(var.client_certificate)

  load_config_file = false
}

provider "helm" {
  kubernetes {
    host                   = var.host
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
    client_key             = base64decode(var.client_key)
    client_certificate     = base64decode(var.client_certificate)
  }
}

provider kubernetes {
  host                   = var.host
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  client_key             = base64decode(var.client_key)
  client_certificate     = base64decode(var.client_certificate)
}

