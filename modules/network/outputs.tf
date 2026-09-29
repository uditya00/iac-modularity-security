output "network_name" {
  description = "Name of the Docker network (used by the compute module)."
  value       = docker_network.this.name
}
