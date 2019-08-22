# Manual resource "azurerm_app_service_plan" "asp" {
  name                = "${var.app_service_plan_name}-asp"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "as" {
  name                = "${var.app_service_name}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  app_service_plan_id = "${azurerm_app_service_plan.asp.id}"
}