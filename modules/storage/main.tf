resource "docker_volume" "this" {
  name = "${var.name_prefix}-data"
}
