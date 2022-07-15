locals {
  opa_ext_authz_spec = <<EOT
configPatches:
- applyTo: HTTP_FILTER
  match:
    context: SIDECAR_INBOUND
    listener:
      filterChain:
        filter:
          name: "envoy.filters.network.http_connection_manager"
          subFilter:
            name: "envoy.filters.http.router"
  patch:
    operation: INSERT_BEFORE
    value:
      name: envoy.filters.http.ext_authz
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.filters.http.ext_authz.v3.ExtAuthz
        transport_api_version: V3
        with_request_body:
          max_request_bytes: 8192
          allow_partial_message: true
        failure_mode_allow: false
        metadata_context_namespaces:
          - envoy.filters.http.header_to_metadata
        grpc_service:
          google_grpc:
            target_uri: 127.0.0.1:9191
            stat_prefix: ext_authz
          timeout: 0.5s
- applyTo: HTTP_FILTER
  match:
    context: SIDECAR_INBOUND
    listener:
      filterChain:
        filter:
          name: "envoy.filters.network.http_connection_manager"
          subFilter:
            name: "envoy.filters.http.ext_authz"
  patch:
    operation: INSERT_BEFORE
    value:
      name: envoy.filters.http.header_to_metadata
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.filters.http.header_to_metadata.v3.Config
        request_rules:
        - header: x-opa-authz
          on_header_missing:
            key: 'policy_type'
            value: 'ingress'
- applyTo: HTTP_FILTER
  match:
    context: SIDECAR_OUTBOUND
    listener:
      portNumber: 80
      filterChain:
        filter:
          name: "envoy.filters.network.http_connection_manager"
          subFilter:
            name: "envoy.filters.http.router"
  patch:
    operation: INSERT_BEFORE
    value:
      name: envoy.filters.http.ext_authz
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.filters.http.ext_authz.v3.ExtAuthz
        transport_api_version: V3
        with_request_body:
          max_request_bytes: 8192
          allow_partial_message: true
        failure_mode_allow: false
        metadata_context_namespaces:
          - envoy.filters.http.header_to_metadata
        grpc_service:
          google_grpc:
            target_uri: 127.0.0.1:9191
            stat_prefix: ext_authz
          timeout: 0.5s
- applyTo: HTTP_FILTER
  match:
    context: SIDECAR_OUTBOUND
    listener:
      portNumber: 80
      filterChain:
        filter:
          name: "envoy.filters.network.http_connection_manager"
          subFilter:
            name: "envoy.filters.http.ext_authz"
  patch:
    operation: INSERT_BEFORE
    value:
      name: envoy.filters.http.header_to_metadata
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.filters.http.header_to_metadata.v3.Config
        request_rules:
        - header: x-opa-authz
          on_header_missing:
            key: 'policy_type'
            value: 'egress'
EOT
}

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
    name = "istio-ingress"
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
