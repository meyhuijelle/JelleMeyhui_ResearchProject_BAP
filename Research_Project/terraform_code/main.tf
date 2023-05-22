

variable filename {
  default = "../Attachments/powerautomate.csv"
}



locals {
  contents = csvdecode(file(var.filename))

}

output "line_count" {
  value = length(local.contents)
}



output "line_countdelendoor2" {
  value = length(local.contents) % 2
}



terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}


