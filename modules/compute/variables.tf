variable "name_prefix" {
  description = "Prefix used to name resources."
  type        = string
}

variable "network_name" {
  description = "Docker network to attach to (output of the network module)."
  type        = string
}

variable "volume_name" {
  description = "Volume to mount (output of the storage module)."
  type        = string
}

variable "host_port" {
  description = "Port on your machine (127.0.0.1) that maps to the web server."
  type        = number
  default     = 8080
}

variable "memory_mb" {
  description = "Memory limit for the container in MB."
  type        = number
  default     = 128
}
