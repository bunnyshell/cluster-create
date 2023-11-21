resource "kubernetes_persistent_volume_claim" "nfs_server_pvc" {
  metadata {
    name = "nfs-server-pvc"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "hcloud-volumes"
    resources {
      requests = {
        storage = "20Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "nfs_server_deployment" {
  metadata {
    name = "nfs-server-bns"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "bns-nfs-server"
      }
    }

    template {
      metadata {
        labels = {
          app = "bns-nfs-server"
        }
      }

      spec {
        container {
          name = "nfs-server-bns"
          image = "itsthenetwork/nfs-server-alpine:latest"
          volume_mount {
            name = "nfs-storage"
            mount_path = "/nfsshare"
          }
          env {
            name = "SHARED_DIRECTORY"
            value = "/nfsshare"
          }
          port {
            name = "nfs"
            container_port = 2049
          }
          security_context {
            privileged = true
          }
        }

        volume {
          name = "nfs-storage"

          persistent_volume_claim {
            claim_name = "nfs-server-pvc"
          }
        }
      }
    } 
  }
}

resource "kubernetes_service" "nfs_server_service" {
  metadata {
    name = "srv-nfs-server-bns"
    namespace = var.namespace
    labels = {
      app = "nfs-server-bns"
    }
  }

  spec {
    port {
      name = "nfs-server"
      port = 2049
      protocol = "TCP"
      target_port = 2049
    }
    selector = {
      app = "bns-nfs-server"
    }
  }
}

data "kubernetes_service" "nfs_server_service" {
  metadata {
    name = "srv-nfs-server-bns"
    namespace = var.namespace
  }

  depends_on = [ kubernetes_service.nfs_server_service ]
}

resource "helm_release" "nfs_provisioner" {
  name       = "nfs-subdir-external-provisioner"

  repository = "https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner"
  chart      = "nfs-subdir-external-provisioner"
  version    = "4.0.16"
  namespace  = var.namespace

  set {
    name  = "nfs.path"
    value = "/"
  }

  set {
    name  = "storageClass.name"
    value = "bns-network-sc"
  }

  set {
    name  = "nfs.mountOptions"
    value = "{nfsvers=4.1,proto=tcp}"
  }

  set {
    name  = "nfs.server"
    value = data.kubernetes_service.nfs_server_service.spec[0].cluster_ip
  }
}

resource "kubectl_manifest" "disk_vol_sc" {
  yaml_body = <<YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: bns-disk-sc
provisioner: csi.hetzner.cloud
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
parameters:
  type: pd-balanced
YAML
}
