resource "kubernetes_namespace" "client" {
  metadata {
    name   = "client"
  }
}

resource "kubernetes_deployment" "client" {
  metadata {
    name      = "client"
    namespace = kubernetes_namespace.client.metadata.0.name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "client"
      }
    }
    template {
      metadata {
        name   = "client"
        labels = {
          app = "client"
        }
      }
      spec {
        container {
          name  = "client"
          image = "docker.io/nginx:1.23.0"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
  depends_on = [kubernetes_stateful_set_v1.slp_istio_app]
}