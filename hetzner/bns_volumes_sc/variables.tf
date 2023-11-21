variable "host" {
  type: string
  description: "Retrieve this from the kube config file generated for your cluster. This value maps to clusters.cluster.server"
}
variable "cluster_ca_certificate" {
  type: string
  description: "Retrieve this from the kube config file generated for your cluster. This value maps to clusters.cluster.certificate-authority-data"
}
variable "client_key" {
  type: string
  description: "Retrieve this from the kube config file generated for your cluster. This value maps to users.user.client-key-data"
}
variable "client_certificate" {
  type: string
  description: "Retrieve this from the kube config file generated for your cluster. This value maps to users.user.client-certificate-data"
}

variable "namespace" {
  type    = string
  default = "default"
}
