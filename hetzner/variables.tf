variable "hcloud_token" {
  sensitive = true
  default   = ""
}

variable "ssh_public_key" {
  sensitive = true
}

variable "ssh_private_key" {
  sensitive = true
}


variable "cluster_name" {
  type        = string
  description = "Name to be used for the Hetzner cluster"
}


variable "control_plane_server_type" {
  type        = string
  description = "Hetzner server type for control plane nodes"
}

variable "control_plane_location" {
  type        = string
  description = "Hetzner server data center for control plane nodes"
}


variable "workloads_server_type" {
  type        = string
  description = "Hetzner server type for workloads nodes"
}

variable "workloads_location" {
  type        = string
  description = "Hetzner server data center for workloads nodes"
}

variable "workloads_min_nodes" {
  type        = number
  description = "Min workloads nodes"
}

variable "workloads_max_nodes" {
  type        = number
  description = "Max workloads nodes"
}
