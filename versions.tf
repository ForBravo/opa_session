terraform {
  required_version = ">= 1.1.7"

  required_providers {
    shell = {
      source  = "scottwinkler/shell"
      version = "~> 1.7.10"
    }
    kubernetes = {
      version = "~> 2.12.1"
    }
    helm = {
      version = "~> 2.6.0"
    }
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 0.28.1"
    }
  }
}
