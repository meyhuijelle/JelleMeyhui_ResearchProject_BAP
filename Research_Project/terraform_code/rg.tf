resource "azurerm_resource_group" "RG1" {
  count    = length(local.contents)
  name     = local.contents[count.index].name
  location = local.contents[count.index].location
}