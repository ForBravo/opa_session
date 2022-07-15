resource "kubernetes_namespace" "client" {
  metadata {
    name = "client"
  }
}

resource "kubernetes_pod_v1" "name" {
  metadata {
    name      = "client"
    namespace = kubernetes_namespace.client.metadata.0.name
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
  depends_on = [kubernetes_stateful_set_v1.slp_istio_app]
}