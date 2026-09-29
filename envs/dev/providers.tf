# Talks to your local Docker through its socket. No credentials needed.
provider "docker" {}

# Connects Terraform to the k3d Kubernetes cluster.
provider "kubernetes" {
  config_path = "~/.kube/config"
}
