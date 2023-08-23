resource "azurerm_resource_group" "rg" {
  location = local.region
  name     = "${local.name}-rg"
}
