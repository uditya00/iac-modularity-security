resource "docker_network" "this" {
  name   = "${var.name_prefix}-net"
  driver = "bridge"

  ipam_config {
    subnet = var.subnet_cidr
  }
}
