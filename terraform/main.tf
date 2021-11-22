resource "helm_release" "split-me-release" {
  name       = "split-me-release"
  repository = "https://rbalusup.github.io/Helm3"
  chart      = "split-me-chart"
  namespace = "default"
}