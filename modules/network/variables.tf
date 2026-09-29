variable "name_prefix" {
  description = "Prefix used to name resources."
  type        = string
}

variable "subnet_cidr" {
  description = "Private address range of the Docker network."
  type        = string
  default     = "172.28.0.0/24"
}
