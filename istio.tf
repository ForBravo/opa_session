resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

resource "helm_release" "base" {
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  name       = "base"
  namespace  = kubernetes_namespace.istio_system.metadata.0.name
}

resource "kubernetes_namespace" "istio_ingress" {
  metadata {
    name   = "istio-ingress"
    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "helm_release" "istiod" {
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  name       = "istiod"
  namespace  = kubernetes_namespace.istio_system.metadata.0.name
  depends_on = [helm_release.base]
}

resource "helm_release" "gateway" {
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  name       = "gateway"
  namespace  = kubernetes_namespace.istio_ingress.metadata.0.name
  depends_on = [helm_release.istiod]
}