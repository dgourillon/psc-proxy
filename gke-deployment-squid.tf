

resource "kubernetes_persistent_volume" "squid_volume" {
  metadata {
    name = "terraform-example"
  }
  spec {
    capacity = {
      storage = "2Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      gce_persistent_disk {
        fs_type = "xfs"
        pd_name = "squid-pd"
      }
    }
  }
}


resource "kubernetes_persistent_volume_claim" "squid_volume_claim" {
  metadata {
    name = "squid-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "500M"
      }
    
    }
    volume_name = "${kubernetes_persistent_volume.squid_volume.metadata.0.name}"  

  }
}

resource "kubernetes_service" "squid_service" {
  metadata {
    name = "squid-service"

    labels = {
      app = "squid"
    }
  }

  spec {
    port {
      port = 3128
    }

    selector = {
      app = "squid"
    }
  }
}

resource "kubernetes_deployment" "squid_deployment" {
  metadata {
    name = "squid-deployment"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "squid"
      }
    }

    template {
      metadata {
        labels = {
          app = "squid"
        }
      }

      spec {
        volume {
          name = "squid-config-volume"

          config_map {
            name = "squid-config"

            items {
              key  = "squid"
              path = "squid.conf"
            }
          }
        }

        volume {
          name = "squid-data"

          persistent_volume_claim {
            claim_name = "squid-volume-claim"
          }
        }

        container {
          name  = "squid"
          image = "ubuntu/squid:edge"

          port {
            name           = "squid"
            container_port = 3128
            protocol       = "TCP"
          }

          volume_mount {
            name       = "squid-config-volume"
            mount_path = "/etc/squid/squid.conf"
            sub_path   = "squid.conf"
          }

          volume_mount {
            name       = "squid-data"
            mount_path = "/var/spool/squid"
          }
        }
      }
    }
  }
}