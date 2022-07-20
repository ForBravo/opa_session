resource "kubernetes_namespace" "app" {
  metadata {
    name = "app"
    labels = {
      opa-istio-injection = "enabled"
      istio-injection     = "enabled"
    }
  }
  depends_on = [
    kubernetes_mutating_webhook_configuration_v1.opa_istio_admission_controller,
    helm_release.gateway
  ]
}

resource "kubernetes_manifest" "opa_ext_authz" {
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "EnvoyFilter"
    metadata = {
      name      = "opa-ext-authz"
      namespace = kubernetes_namespace.app.metadata.0.name
    }
    spec = yamldecode(local.opa_ext_authz_spec)
  }
}

resource "kubernetes_config_map_v1" "opa_istio_config" {
  metadata {
    name      = "opa-istio-config"
    namespace = kubernetes_namespace.app.metadata.0.name
  }
  data = {
    "conf.yaml" = <<EOT
discovery:
  name: discovery
  service: styra
labels:
  system-id: ${var.system_id}
  system-type: template.istio:1.0
services:
- name: styra
  url: http://slp-istio-svc:8080/v1
- name: styra-bundles
  url: http://slp-istio-svc:8080/v1/bundles
EOT
  }
}

resource "kubernetes_secret_v1" "slp_istio" {
  metadata {
    name      = "slp-istio"
    namespace = kubernetes_namespace.app.metadata.0.name
    labels = {
      app         = "slp"
      system-type = "istio"
    }
  }
  data = {
    "slp.yaml" = <<EOT
discovery:
  name: discovery
  prefix: /systems/${var.system_id}
  service: styra
labels:
  system-id: ${var.system_id}
  system-type: template.istio:1.0
services:
- credentials:
    bearer:
      token: ${var.styra_system_token}
  name: styra
  url: ${var.styra_host}/v1
- credentials:
    bearer:
      token: ${var.styra_system_token}
  name: styra-bundles
  url: ${var.styra_host}/v1/bundles
EOT
  }
}

resource "kubernetes_stateful_set_v1" "slp_istio_app" {

  metadata {
    name      = "slp-istio-app"
    namespace = kubernetes_namespace.app.metadata.0.name
    labels = {
      app         = "slp"
      system-type = "istio"
    }
  }
  spec {
    replicas     = 1
    service_name = "slp-istio-app"
    selector {
      match_labels = {
        app         = "slp"
        system-type = "istio"
      }
    }
    template {
      metadata {
        labels = {
          "sidecar.istio.io/inject" = "false"
          app                       = "slp"
          system-type               = "istio"
        }
        annotations = {
          check-sum = md5(jsonencode(kubernetes_secret_v1.slp_istio.data))
        }
      }
      spec {
        container {
          name  = "slp"
          image = "styra/styra-local-plane:0.4.4"
          args = [
            "--config-file=/config/slp.yaml",
            "--addr=0.0.0.0:8080"
          ]
          liveness_probe {
            http_get {
              path = "/v1/system/alive"
              port = "8000"
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
          readiness_probe {
            http_get {
              path = "/v1/system/ready"
              port = "8000"
            }
            initial_delay_seconds = 10
            period_seconds        = 5
          }
          volume_mount {
            read_only  = true
            mount_path = "/config/slp.yaml"
            sub_path   = "slp.yaml"
            name       = "slp-config-vol"
          }
          volume_mount {
            mount_path = "/scratch"
            name       = "slp-scratch-vol"
          }
        }
        volume {
          name = "slp-config-vol"
          secret {
            secret_name = "slp-istio"
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "slp-scratch-vol"
        labels = {
          slp-pvc : "slp-istio-app-pvc"
        }
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "2Gi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "slp_istio_svc" {
  metadata {
    name      = "slp-istio-svc"
    namespace = kubernetes_namespace.app.metadata.0.name
    labels = {
      app         = "slp"
      system-type = "istio"
    }
  }
  spec {
    port {
      port        = 8080
      protocol    = "TCP"
      target_port = 8080
    }
    selector = {
      app         = "slp"
      system-type = "istio"
    }
  }
}

resource "kubernetes_service" "app_svc" {
  metadata {
    name      = "app-svc"
    namespace = kubernetes_namespace.app.metadata.0.name
    labels = {
      app = "app"
    }
  }
  spec {
    port {
      port        = 80
      protocol    = "TCP"
      target_port = 8080
    }
    selector = {
      app = "app"
    }
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "app"
    namespace = kubernetes_namespace.app.metadata.0.name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "app"
      }
    }
    template {
      metadata {
        name = "app"
        labels = {
          app = "app"
        }
      }
      spec {
        container {
          name  = "app"
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