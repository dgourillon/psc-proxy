resource "kubernetes_storage_class" "standard" {
  metadata {
    name = "standard"
  }

  parameters = {
    fstype = "ext4"
    replication-type = "none"
    type = "pd-standard"
  }

  reclaim_policy         = "Delete"
  allow_volume_expansion = true
  volume_binding_mode    = "Immediate"
}



resource "kubernetes_persistent_volume_claim" "squid_volume_claim" {
  metadata {
    name = "squid-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "standard"
    resources {
      requests = {
        storage = "500M"
      }
    }


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