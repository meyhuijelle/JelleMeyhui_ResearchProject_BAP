resource "azurerm_virtual_network" "VNET1" {
  count               = length(local.contents)
  name                = "vnet-${local.contents[count.index].name}"
  location            = local.contents[count.index].location
  resource_group_name = local.contents[count.index].name
  address_space       = ["192.168.0.0/16"]
  depends_on = [
    azurerm_resource_group.RG1
  ]
}

resource "azurerm_subnet" "subnet1" {
    count               = length(local.contents)
    name                 = "subnet-${local.contents[count.index].name}"
    resource_group_name = local.contents[count.index].name
    virtual_network_name = azurerm_virtual_network.VNET1[count.index].name
    address_prefixes     = ["192.168.10.0/24"]  
    depends_on = [
      azurerm_virtual_network.VNET1
    ]
}

resource "azurerm_public_ip" "pubIP" {
    count               = length(local.contents)
    name                = "pubIP-${local.contents[count.index].name}"
    location            = local.contents[count.index].location
    resource_group_name = local.contents[count.index].name
    allocation_method   = "Static"
    depends_on = [
      azurerm_virtual_network.VNET1
    ]
}