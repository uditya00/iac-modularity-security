resource "docker_network" "this" {
  name       = "${var.name_prefix}-net"
  driver     = "bridge"
  attachable = false
  ingress    = false
  internal   = false
  ipv6       = false

  ipam_config {
    subnet  = var.subnet_cidr
    gateway = "172.28.0.1"
  }
}
