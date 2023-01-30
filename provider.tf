terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~>2.0"
    }
  }
}

variable "do_token" {}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_container_registry" "hitorilabs" {
  name                      = "hitorilabs"
  subscription_tier_slug    = "starter"
  region                    = "nyc3"
}

resource "digitalocean_app" "demo" {
  spec {
    name   = "demo"
    region = "tor"

    domain {
      name = "api.hitorilabs.com"
      type = "PRIMARY"
    }

    alert {
      rule = "DEPLOYMENT_FAILED"
    }

    alert {
      rule = "DOMAIN_FAILED"
    }

    service {
      name               = "fastapi-service"
      instance_count     = 1
      instance_size_slug = "basic-xxs"
      http_port          = 8080

      routes {
        path = "/"
      }

      image {
        registry_type = "DOCR"
        repository    = "fastapi-server"
        tag           = "latest"
        deploy_on_push {
          enabled = true
        }
      }
    }
  }
}
