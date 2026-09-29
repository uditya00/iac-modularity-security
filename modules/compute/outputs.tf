output "container_name" {
  description = "Name of the running container."
  value       = docker_container.this.name
}

output "url" {
  description = "Local URL of the web server."
  value       = "http://127.0.0.1:${var.host_port}"
}
