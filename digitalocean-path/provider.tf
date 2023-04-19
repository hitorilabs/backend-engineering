terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~>2.0"
    }
  }
}

# Define a variable so we can pass in our token
variable "do_pat" {
  type = string
  description = "A token to authenticate with Doppler"
}

# Define a variable so we can pass in our token
variable "main_vpc_id" {
  type = string
  description = "The ID of the main VPC"
}

provider "digitalocean" {
  token = var.do_pat
}

resource "digitalocean_vpc" "hitorilabs-vpc" {
  name     = "vpc-hitorilabs"
  region   = "tor1"
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

resource "digitalocean_database_cluster" "hitorilabs-cluster" {
  name       = "hitorilabs-cluster"
  engine     = "mongodb"
  version    = "4"
  size       = "db-s-1vcpu-1gb"
  region     = "tor1"
  node_count = 1
  private_network_uuid = var.main_vpc_id
}