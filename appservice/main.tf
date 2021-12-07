provider "azurerm" {
  features {}
}

locals {
  current_time = formatdate("MMM DD, YYYY hh:mm:ss", timestamp())
  tags         = merge({ "NS_Application" = var.NS_Application }, { "NS_Environment" = var.NS_Environment }, { "Last_Modified" = local.current_time }, { "NS_Location" = var.location })
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.appname}-rg"
  location = var.location
  tags     = local.tags
}

resource "azurerm_app_service_plan" "asp" {
  name                = "${var.appname}-asp"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = var.kind
  reserved            = true
  sku {
    tier = var.appsku
    size = var.appsize
  }
  tags = local.tags

}

resource "azurerm_app_service" "appserv" {
  name                = var.appname
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.asp.id

  tags = local.tags

}
