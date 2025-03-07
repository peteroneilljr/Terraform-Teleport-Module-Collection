# https://goteleport.com/docs/ver/15.x/deploy-a-cluster/helm-deployments/kubernetes-cluster/#install-the-teleport-cluster-helm-chart
# creates namespace for teleport cluster 
resource "kubernetes_namespace" "teleport_cluster" {
  metadata {
    name = "teleport-cluster"
    labels = {
      "pod-security.kubernetes.io/enforce" = "baseline"
    }
  }
}
# Read Teleport Enterprise License
data "local_sensitive_file" "license" {
  filename = var.teleport_license_filepath
}
# creates enterprise license as k8s secret
resource "kubernetes_secret" "license" {
  metadata {
    name      = "license"
    namespace = kubernetes_namespace.teleport_cluster.metadata[0].name
  }
  data = {
    "license.pem" = data.local_sensitive_file.license.content
  }
  type = "Opaque"
}

# defines helm release for teleport cluster
# https://goteleport.com/docs/reference/helm-reference/teleport-cluster
resource "helm_release" "teleport_cluster" {
  namespace = kubernetes_namespace.teleport_cluster.metadata[0].name
  wait      = true
  timeout   = 300

  name = "teleport-cluster"

  repository = "https://charts.releases.teleport.dev"
  chart      = "teleport-cluster"
  version    = var.teleport_version
  values = [
    <<EOF
clusterName: "${var.teleport_subdomain}.${var.aws_domain_name}"
chartMode: standalone
proxyListenerMode: multiplex
acme: true
acmeEmail: "${var.teleport_email}"
enterprise: true
persistence:
  storageClassName: gp2
operator:
  enabled: true
EOF
  ]
}

