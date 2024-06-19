provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-rg"
  location = "East US"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "aksdns"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }
}

resource "kubernetes_namespace" "uptime_kuma" {
  metadata {
    name = "uptime-kuma"
  }
}

resource "kubernetes_deployment" "uptime_kuma" {
  metadata {
    name      = "uptime-kuma"
    namespace = kubernetes_namespace.uptime_kuma.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "uptime-kuma"
      }
    }

    template {
      metadata {
        labels = {
          app = "uptime-kuma"
        }
      }

      spec {
        container {
          name  = "uptime-kuma"
          image = "louislam/uptime-kuma:1"

          port {
            container_port = 3001
          }

          volume_mount {
            mount_path = "/app/data"
            name       = "uptime-kuma-storage"
          }
        }

        volume {
          name = "uptime-kuma-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.uptime_kuma.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "uptime_kuma" {
  metadata {
    name      = "uptime-kuma"
    namespace = kubernetes_namespace.uptime_kuma.metadata[0].name
  }

  spec {
    selector = {
      app = "uptime-kuma"
    }

    port {
      port        = 3001
      target_port = 3001
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_persistent_volume_claim" "uptime_kuma" {
  metadata {
    name      = "uptime-kuma-pvc"
    namespace = kubernetes_namespace.uptime_kuma.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}
