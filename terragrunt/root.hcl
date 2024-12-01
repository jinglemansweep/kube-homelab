locals {
  terraform_cloud_workspace_prefix = "kubehomelab"
  environment = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

generate "backend" {
  path      = "_backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.5"
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "peachtrees"
    workspaces {
      name = "${local.terraform_cloud_workspace_prefix}-${local.environment.locals.env_slug}-${local.region.locals.region_slug}"
    }
  }
  required_providers {
    infisical = {
      source = "infisical/infisical"
      version = "~> 0.3"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.1"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.7.0-alpha.0"
    }
  }
}
EOF
}

generate "provider_infisical" {
  path      = "_provider_infisical.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
variable "infisical_workspace_id" {}
variable "infisical_client_id" {}
variable "infisical_client_secret" {}
provider "infisical" {
  host          = "https://app.infisical.com"
  client_id     = var.infisical_client_id
  client_secret = var.infisical_client_secret
}
data "infisical_secrets" "secrets" {
  env_slug    = "prod"
  workspace_id = var.infisical_workspace_id
  folder_path = "/"
}
EOF
}

inputs = merge(
  local.environment.locals,
  local.region.locals
)