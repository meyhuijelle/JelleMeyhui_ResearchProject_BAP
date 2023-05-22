resource "azurerm_lb" "lb" {
  count               = length(local.contents)
  name                = "lb-${local.contents[count.index].name}"
  location            = local.contents[count.index].location
  resource_group_name = local.contents[count.index].name

  frontend_ip_configuration {
    name = "lb-feIP-${local.contents[count.index].name}"
    # public_ip_address_id = azurerm_public_ip.pubIP.id
    public_ip_address_id = azurerm_public_ip.pubIP[count.index].id

  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend_pool" {
  count               = length(local.contents)
  name                = "bePool-${local.contents[count.index].name}"
  # resource_group_name = azurerm_resource_group.RG1.name
  loadbalancer_id     = azurerm_lb.lb[count.index].id
}

resource "azurerm_lb_backend_address_pool" "lb_backend_pool_22" {
  count               = length(local.contents)
  name                = "bePool-P22-${local.contents[count.index].name}"
  # resource_group_name = azurerm_resource_group.RG1.name
  loadbalancer_id     = azurerm_lb.lb[count.index].id
}

resource "azurerm_lb_backend_address_pool" "lb_backend_pool_23" {
  count               = length(local.contents)
  name                = "bePool-P23-${local.contents[count.index].name}"
  # resource_group_name = azurerm_resource_group.RG1.name
  loadbalancer_id     = azurerm_lb.lb[count.index].id
}

# resource "azurerm_lb_probe" "lb_probe" {
#   count               = length(local.contents)
#   name                = "lb-probe-${local.contents[count.index].name}"
#   # resource_group_name = azurerm_resource_group.RG1.name
#   loadbalancer_id     = azurerm_lb.lb[count.index].id
#   port                = 80
#   protocol            = "Tcp"
  
# }

resource "azurerm_lb_rule" "lb_rule" {
  count               = length(local.contents)
  name                = "lb-rule-${local.contents[count.index].name}"
  # resource_group_name = azurerm_resource_group.RG1.name
  loadbalancer_id     = azurerm_lb.lb[count.index].id
  protocol            = "Tcp"
  frontend_port       = 80
  backend_port        = 80
  frontend_ip_configuration_name = "lb-feIP-${local.contents[count.index].name}"
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_backend_pool[count.index].id]
#   probe_id          = azurerm_lb_probe.lb_probe[count.index].id

  depends_on = [
    azurerm_lb.lb
  ]
}

resource "azurerm_lb_rule" "lb_rule2" {
  count               = length(local.contents)
  name                = "lb-rule2-${local.contents[count.index].name}"
  # resource_group_name = azurerm_resource_group.RG1.name
  loadbalancer_id     = azurerm_lb.lb[count.index].id
  protocol            = "Tcp"
  frontend_port       = 22
  backend_port        = 22
  frontend_ip_configuration_name = "lb-feIP-${local.contents[count.index].name}"
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_backend_pool_22[count.index].id]
#   probe_id          = azurerm_lb_probe.lb_probe[count.index].id

  depends_on = [
    azurerm_lb.lb
  ]
}

resource "azurerm_lb_rule" "lb_rule3" {
  count               = length(local.contents)
  name                = "lb-rule3-${local.contents[count.index].name}"
  # resource_group_name = azurerm_resource_group.RG1.name
  loadbalancer_id     = azurerm_lb.lb[count.index].id
  protocol            = "Tcp"
  frontend_port       = 23
  backend_port        = 22
  frontend_ip_configuration_name = "lb-feIP-${local.contents[count.index].name}"
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_backend_pool_23[count.index].id]
#   probe_id          = azurerm_lb_probe.lb_probe[count.index].id

  depends_on = [
    azurerm_lb.lb
  ]
}