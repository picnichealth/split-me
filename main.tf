terraform {
  backend "kubernetes" {
    secret_suffix    = "state"
    load_config_file = true
  }

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.4.1"
    }
  }
}

provider "helm" {
  alias = "local"
  experiments {
    manifest = true
  }
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

variable "namespace" {
  type = string
}

resource "helm_release" "docker-registry" {
  provider         = "helm.local"
  name             = "docker-registry"
  chart            = "./helm/docker-registry"
  namespace        = var.namespace
  create_namespace = true
  atomic           = true
}

resource "null_resource" "build-image" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "make build-image"
  }
}

resource "null_resource" "push-image" {
  depends_on = [helm_release.docker-registry]

  triggers = {
    build_image_Id : null_resource.build-image.id
  }

  provisioner "local-exec" {
    command = "make push-image"
  }
}

resource "helm_release" "split-me" {
  depends_on = [null_resource.push-image]
  provider   = "helm.local"

  name             = "split-me"
  chart            = "./helm/split-me"
  namespace        = var.namespace
  lint             = true
  create_namespace = true
  atomic           = true
}

resource "helm_release" "prometheus" {
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus"
  name             = "prometheus"
  namespace        = "split-me-monitoring"
  lint             = true
  create_namespace = true
  atomic           = true

  values = [file("helm/values/prometheus.yaml")]
}

resource "helm_release" "grafana" {
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  name             = "grafana"
  namespace        = "split-me-monitoring"
  lint             = true
  create_namespace = true
  atomic           = true
  values           = [file("helm/values/grafana.yaml")]
}
