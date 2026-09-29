terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }

  # Remote state in PostgreSQL. Postgres locks the state automatically.
  # The connection string (with password) comes from the PG_CONN_STR
  # environment variable, so nothing secret is written in code.
  backend "pg" {}
}
