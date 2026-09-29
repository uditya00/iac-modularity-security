variable "project_name" {
  description = "Short project name used in resource names."
  type        = string
  default     = "iacdemo"
}

variable "environment" {
  description = "Environment name (dev, test, prod)."
  type        = string
  default     = "dev"
}

variable "host_port" {
  description = "Local port for the web server."
  type        = number
  default     = 8080
}
