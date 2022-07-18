resource "kubernetes_namespace" "opa_istio" {
  metadata {
    name = "opa-istio"
  }
}

resource "kubernetes_service" "opa_istio_admission_controller" {
  metadata {
    name      = "admission-controller"
    namespace = kubernetes_namespace.opa_istio.metadata.0.name
  }
  spec {
    port {
      port = 443
      name = "https"
    }
    selector = {
      app = "admission-controller"
    }
  }
}

resource "kubernetes_secret_v1" "server_cert" {
  metadata {
    name      = "server-cert"
    namespace = kubernetes_namespace.opa_istio.metadata.0.name
  }
  data = {
    "tls.crt" = <<EOT
-----BEGIN CERTIFICATE-----
MIIFYDCCA0igAwIBAgIJAIVbQs/j7VbCMA0GCSqGSIb3DQEBCwUAMBsxGTAXBgNV
BAMMEE9QQSBFbnZveSBwbHVnaW4wHhcNMjAxMTIzMTA0NDM4WhcNMjUxMTIyMTA0
NDM4WjAUMRIwEAYDVQQDDAlvcGEtZW52b3kwggIiMA0GCSqGSIb3DQEBAQUAA4IC
DwAwggIKAoICAQD+l+ai5IAzVqsu4FQm6DIrVZ55GWfQnAbPlKo9yTKS8xQ5PM6J
0r8Kdm4NErGeEERLCzqmGuoNDhqil0A6MTWwhn+mqMISSB55feT0KkecX9Kk//89
13xQ0U9ViMJ/l+toEpAPrpTcXI0rT7AaFpNdkH642bBGRHmpd+YiXTcTfyqz6dve
wendNpDPrB9Pw97Y9jlTmvSi5iTVj2+YJgwkmKBtFTsjVGHOefgAHqDhoC8Nhhp0
aLjM3shhi3bTwP6V5NOmvvuKRmm7zfk7LUBYNLX6fXIzCpR1PJAxgkkMTZP6cXE4
+vn1jJ7m/edqYTu2+n6tGPXUROaY+3MNEMnn1cVs1TKCncnagStoqFwnhVjN26Uu
17sZnf+l5qOwGbNclx7HrF6HsiShA+138NimKxnfmCyvbvI8pX1I11uyK0zZh62N
DpOuMDUaFBWdGNoxcp5qDpsVjw1S2BYjdfWnO5ceg9ZssJcMUqa8tHuQwz0DF8oq
rxb80VN053qiiBuBPh81ZQBvEz+S0DEjGOqCg0lOWHLY7KjpRmHyMZ9+Ft4tMAOu
oBiAsbghJuLDFynIGqCP5/u8swA7RPyJ81nZuuMfJU9GRqu9H2vQ3s4Wc9EEvZdi
6vaL+bqyR4Rr6X4azgoVFFP5w4xY0BGVxYczqiRNw8pte6nRZXlfNbOSNQIDAQAB
o4GtMIGqMA4GA1UdDwEB/wQEAwIDuDATBgNVHSUEDDAKBggrBgEFBQcDATAdBgNV
HQ4EFgQUKXS7kTGae8tKYZvRLRS5xSHwq4EwNQYDVR0jBC4wLKEfpB0wGzEZMBcG
A1UEAwwQT1BBIEVudm95IHBsdWdpboIJANaObQBFP01iMC0GA1UdEQQmMCSCImFk
bWlzc2lvbi1jb250cm9sbGVyLm9wYS1pc3Rpby5zdmMwDQYJKoZIhvcNAQELBQAD
ggIBAKtqef4tMvGxBeM1+/Fe4q9V+9Jn0qJoP4ieSApwhkqzAJbYIRz6VCk+evZE
Xvv25BBeNID0wjWoXDtwS1X+CHd7ByLGK66D2+pezE7HCzxCELJ4+iYtcKrUA4ve
WnEgInjkUioy0fDdZeTXnHIIiy9IUVDT9q7lGjQ4axbIGz6G3ceGQ+X9QB00333H
o6zf9kQksXPjm4ujl9UvgRd45YAm8cqJq4joxGB7F1ZT1RXnGJyv/wqNJM8Td9Pj
asb7IBkOKzXxVdDXNTfcKYN8O3EBL0Tj4TLm3UJRcqxhE6MYUroE6/dr2lxtg4Y/
5JjXZ0bCfrNxyPR351244OZuP334j8C9x5qMXh6T38iKMFZlp6jc0GYMGs+zA4ce
NFZOQ21zdOoGcPKgw42cwObSVZEIt4RH7HUp7CWZB+EiMt1eEJkUdxNcPYwVPfu+
gbIWv6eIzVBI8IAtwTA0Ere5DlPBf2NrNrPurfsb2bgmBQ1IDCzWorRq6XmT1e+z
/3RRaRiULxNanok3LgRkOhX6jGqb3X1F8ptsb+PGRyWp5du/CPAnpfwVumo48mpq
DIIdL1PKfMCdYk0aKgLTVu4l267PxrIihk8HqQXWPaZy42tRUZ9vE5fhnSp1zFAK
q3Z1W1T7i2CPvan59FrHePobkFvgS83vnUqH3hzhfuBZC2cf
-----END CERTIFICATE-----
EOT
    "tls.key" = <<EOT
-----BEGIN RSA PRIVATE KEY-----
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
-----END RSA PRIVATE KEY-----
EOT
  }
}

resource "kubernetes_config_map_v1" "inject_policy" {
  metadata {
    name      = "inject-policy"
    namespace = kubernetes_namespace.opa_istio.metadata.0.name
  }
  data = {
    "inject.rego" = <<EOT
package istio

inject = {
  "apiVersion": "admission.k8s.io/v1beta1",
  "kind": "AdmissionReview",
  "response": {
    "allowed": true,
    "patchType": "JSONPatch",
    "patch": base64.encode(json.marshal(patch)),
  },
}

patch = [{
  "op": "add",
  "path": "/spec/containers/-",
  "value": opa_container,
}, {
  "op": "add",
  "path": "/spec/volumes/-",
  "value": opa_config_volume,
}]

opa_container = {
  "image": "openpolicyagent/opa:0.41.0-envoy-rootless",
  "name": "opa",
  "args": [
    "run",
    "--server",
    "--ignore=.*",
    "--config-file=/config/conf.yaml",
    "--authorization=basic",
    "--addr=http://127.0.0.1:8181",
    "--diagnostic-addr=0.0.0.0:8282"
  ],
  "volumeMounts": [{
    "mountPath": "/config",
    "name": "opa-config-vol",
  }],
  "readinessProbe": {
    "httpGet": {
      "path": "/health?bundle=true",
      "port": 8282,
    },
    "initialDelaySeconds": 5,
    "periodSeconds": 5
  },
  "livenessProbe": {
    "httpGet": {
      "path": "/health",
      "port": 8282,
    },
    "initialDelaySeconds": 5,
    "periodSeconds": 5
  }
}

opa_config_volume = {
  "name": "opa-config-vol",
  "configMap": {"name": "opa-istio-config"},
}
EOT
  }
}

resource "kubernetes_deployment_v1" "opa_istio_admission_controller" {
  metadata {
    name      = "admission-controller"
    namespace = kubernetes_namespace.opa_istio.metadata.0.name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "admission-controller"
      }
    }
    template {
      metadata {
        labels = {
          app = "admission-controller"
        }
        annotations = {
          check-sum = md5(jsonencode(merge(kubernetes_config_map_v1.inject_policy.data, kubernetes_secret_v1.server_cert.data)))
        }
        name = "admission-controller"
      }
      spec {
        container {
          name  = "opa"
          image = "openpolicyagent/opa:0.42.1"
          port {
            container_port = 443
          }
          args = [
            "run",
            "--server",
            "--tls-cert-file=/certs/tls.crt",
            "--tls-private-key-file=/certs/tls.key",
            "--addr=0.0.0.0:443",
            "/policies/inject.rego"
          ]
          liveness_probe {
            http_get {
              path   = "/health?plugins"
              scheme = "HTTPS"
              port   = "443"
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
          readiness_probe {
            http_get {
              path   = "/health?plugins"
              scheme = "HTTPS"
              port   = "443"
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
          volume_mount {
            read_only  = true
            mount_path = "/certs"
            name       = "server-cert"
          }
          volume_mount {
            read_only  = true
            mount_path = "/policies"
            name       = "inject-policy"
          }
        }
        volume {
          name = "inject-policy"
          config_map {
            name = "inject-policy"
          }
        }
        volume {
          name = "server-cert"
          secret {
            secret_name = "server-cert"
          }
        }
      }
    }
  }
  timeouts {
    create = "20m"
  }
}

resource "kubernetes_mutating_webhook_configuration_v1" "opa_istio_admission_controller" {
  metadata {
    name = "opa-istio-admission-controller"
  }
  webhook {
    name = "istio.openpolicyagent.org"
    client_config {
      service {
        name      = "admission-controller"
        namespace = "opa-istio"
        path      = "/v0/data/istio/inject"
      }
      ca_bundle = <<EOT
-----BEGIN CERTIFICATE-----
MIIFYDCCA0igAwIBAgIJAIVbQs/j7VbCMA0GCSqGSIb3DQEBCwUAMBsxGTAXBgNV
BAMMEE9QQSBFbnZveSBwbHVnaW4wHhcNMjAxMTIzMTA0NDM4WhcNMjUxMTIyMTA0
NDM4WjAUMRIwEAYDVQQDDAlvcGEtZW52b3kwggIiMA0GCSqGSIb3DQEBAQUAA4IC
DwAwggIKAoICAQD+l+ai5IAzVqsu4FQm6DIrVZ55GWfQnAbPlKo9yTKS8xQ5PM6J
0r8Kdm4NErGeEERLCzqmGuoNDhqil0A6MTWwhn+mqMISSB55feT0KkecX9Kk//89
13xQ0U9ViMJ/l+toEpAPrpTcXI0rT7AaFpNdkH642bBGRHmpd+YiXTcTfyqz6dve
wendNpDPrB9Pw97Y9jlTmvSi5iTVj2+YJgwkmKBtFTsjVGHOefgAHqDhoC8Nhhp0
aLjM3shhi3bTwP6V5NOmvvuKRmm7zfk7LUBYNLX6fXIzCpR1PJAxgkkMTZP6cXE4
+vn1jJ7m/edqYTu2+n6tGPXUROaY+3MNEMnn1cVs1TKCncnagStoqFwnhVjN26Uu
17sZnf+l5qOwGbNclx7HrF6HsiShA+138NimKxnfmCyvbvI8pX1I11uyK0zZh62N
DpOuMDUaFBWdGNoxcp5qDpsVjw1S2BYjdfWnO5ceg9ZssJcMUqa8tHuQwz0DF8oq
rxb80VN053qiiBuBPh81ZQBvEz+S0DEjGOqCg0lOWHLY7KjpRmHyMZ9+Ft4tMAOu
oBiAsbghJuLDFynIGqCP5/u8swA7RPyJ81nZuuMfJU9GRqu9H2vQ3s4Wc9EEvZdi
6vaL+bqyR4Rr6X4azgoVFFP5w4xY0BGVxYczqiRNw8pte6nRZXlfNbOSNQIDAQAB
o4GtMIGqMA4GA1UdDwEB/wQEAwIDuDATBgNVHSUEDDAKBggrBgEFBQcDATAdBgNV
HQ4EFgQUKXS7kTGae8tKYZvRLRS5xSHwq4EwNQYDVR0jBC4wLKEfpB0wGzEZMBcG
A1UEAwwQT1BBIEVudm95IHBsdWdpboIJANaObQBFP01iMC0GA1UdEQQmMCSCImFk
bWlzc2lvbi1jb250cm9sbGVyLm9wYS1pc3Rpby5zdmMwDQYJKoZIhvcNAQELBQAD
ggIBAKtqef4tMvGxBeM1+/Fe4q9V+9Jn0qJoP4ieSApwhkqzAJbYIRz6VCk+evZE
Xvv25BBeNID0wjWoXDtwS1X+CHd7ByLGK66D2+pezE7HCzxCELJ4+iYtcKrUA4ve
WnEgInjkUioy0fDdZeTXnHIIiy9IUVDT9q7lGjQ4axbIGz6G3ceGQ+X9QB00333H
o6zf9kQksXPjm4ujl9UvgRd45YAm8cqJq4joxGB7F1ZT1RXnGJyv/wqNJM8Td9Pj
asb7IBkOKzXxVdDXNTfcKYN8O3EBL0Tj4TLm3UJRcqxhE6MYUroE6/dr2lxtg4Y/
5JjXZ0bCfrNxyPR351244OZuP334j8C9x5qMXh6T38iKMFZlp6jc0GYMGs+zA4ce
NFZOQ21zdOoGcPKgw42cwObSVZEIt4RH7HUp7CWZB+EiMt1eEJkUdxNcPYwVPfu+
gbIWv6eIzVBI8IAtwTA0Ere5DlPBf2NrNrPurfsb2bgmBQ1IDCzWorRq6XmT1e+z
/3RRaRiULxNanok3LgRkOhX6jGqb3X1F8ptsb+PGRyWp5du/CPAnpfwVumo48mpq
DIIdL1PKfMCdYk0aKgLTVu4l267PxrIihk8HqQXWPaZy42tRUZ9vE5fhnSp1zFAK
q3Z1W1T7i2CPvan59FrHePobkFvgS83vnUqH3hzhfuBZC2cf
-----END CERTIFICATE-----
EOT
    }
    rule {
      api_groups   = ["*"]
      api_versions = ["v1"]
      operations   = ["CREATE"]
      resources    = ["pods"]
    }
    namespace_selector {
      match_labels = {
        opa-istio-injection = "enabled"
      }
    }
    object_selector {
      match_expressions {
        key      = "sidecar.istio.io/inject"
        operator = "NotIn"
        values   = ["false"]
      }
    }
    failure_policy            = "Fail"
    admission_review_versions = ["v1beta1"]
    side_effects              = "None"
  }
}