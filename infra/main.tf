terraform {
  backend "azurerm" {
    subscription_id      = "20c17ce1-c880-4374-ab18-0c3a72158cf7"
    resource_group_name  = "gwa-statefile"
    storage_account_name = "mccrackenyycgwastatefile"
    container_name       = "terraform"
    key                  = "gwa.terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.40.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id

  features {}
}