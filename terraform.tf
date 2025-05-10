terraform {

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "5.97.0"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "cyber-practice"

    workspaces {
      name = "Pipeline-1"
    }

  }
}

