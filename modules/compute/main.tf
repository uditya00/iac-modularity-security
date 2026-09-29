resource "docker_image" "this" {
  name = "${var.name_prefix}-web:1.0"

  build {
    context = "${path.module}/app"
  }
}

resource "docker_container" "this" {
  name  = "${var.name_prefix}-web"
  image = docker_image.this.image_id

  # Security hardening
  user          = "101"
  read_only     = true
  memory        = var.memory_mb
  security_opts = ["no-new-privileges:true"]
  restart       = "unless-stopped"

  capabilities {
    drop = ["ALL"]
  }

  tmpfs = {
    "/tmp" = "rw,noexec,nosuid,size=16m"
  }

  # Only reachable from your own machine, not from the network
  ports {
    internal = 8080
    external = var.host_port
    ip       = "127.0.0.1"
  }

  networks_advanced {
    name = var.network_name
  }

  volumes {
    volume_name    = var.volume_name
    container_path = "/data"
  }

  healthcheck {
    test     = ["CMD", "wget", "-q", "--spider", "http://127.0.0.1:8080/"]
    interval = "30s"
    timeout  = "3s"
    retries  = 3
  }
}
