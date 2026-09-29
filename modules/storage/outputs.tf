output "volume_name" {
  description = "Name of the persistent volume (used by the compute module)."
  value       = docker_volume.this.name
}
