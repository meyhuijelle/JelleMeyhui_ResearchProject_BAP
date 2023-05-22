 resource "azurerm_network_interface" "NIC1" {
   count               = length(local.contents) * 2
   name                = "NIC-${local.contents[count.index % 2].name}${count.index}"
   location            = local.contents[count.index % 2].location
   resource_group_name = local.contents[count.index % 2].name
   depends_on = [
     azurerm_resource_group.RG1,
     azurerm_subnet.subnet1
   ]
  ip_configuration {
    name                          = "IP-Config-${local.contents[count.index % 2].name}${count.index}"
    subnet_id                     = azurerm_subnet.subnet1[count.index % 2].id
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id = azurerm_public_ip.public_ip.id
    # load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_backend_pool.id]
  }
 }

 resource "azurerm_network_interface_backend_address_pool_association" "business-tier-pool" {
  count                   = length(local.contents) * 2
  network_interface_id    = azurerm_network_interface.NIC1.*.id[count.index]
  ip_configuration_name   = "IP-Config-${local.contents[count.index % 2].name}${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_pool[count.index % 2].id
}

 resource "azurerm_network_interface_backend_address_pool_association" "business-tier-pool2" {
  count                   = length(local.contents)
  network_interface_id    = azurerm_network_interface.NIC1.*.id[count.index % 2]
  ip_configuration_name   = "IP-Config-${local.contents[count.index % 2].name}${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_pool_22[count.index].id
}

 resource "azurerm_network_interface_backend_address_pool_association" "business-tier-pool3" {
  count                   = length(local.contents)
  network_interface_id    = azurerm_network_interface.NIC1[count.index + 2].id
  ip_configuration_name   = "IP-Config-${local.contents[count.index % 2].name}${count.index + 2}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_pool_23[count.index].id
}

 resource "azurerm_managed_disk" "managed_disk1" {
   count                = length(local.contents) * 2
   name                 = "datadisk-existing-${local.contents[count.index % 2].name}${count.index}"
   location             = local.contents[count.index % 2].location
   resource_group_name  = local.contents[count.index % 2].name
   storage_account_type = "Standard_LRS"
   create_option        = "Empty"
   disk_size_gb         = "1023"
   depends_on = [
     azurerm_resource_group.RG1
   ]
 }

resource "azurerm_availability_set" "example" {
  count               = length(local.contents)
  name                = "example-aset${count.index}"
  location            = local.contents[count.index % 2].location
  resource_group_name = local.contents[count.index % 2].name
  depends_on = [
    azurerm_resource_group.RG1
  ]
}

 resource "azurerm_virtual_machine" "VMsWebserver1" {
   count                 = length(local.contents)
   name                  = "Webserver-${local.contents[count.index].name}-1"
   location              = local.contents[count.index].location
  #  availability_set_id   = azurerm_availability_set.avset[count.index].id
   resource_group_name   = local.contents[count.index].name
   network_interface_ids = [element(azurerm_network_interface.NIC1.*.id, count.index)]
   vm_size               = "Standard_DS1_v2"

   # Uncomment this line to delete the OS disk automatically when deleting the VM
   delete_os_disk_on_termination = true

   # Uncomment this line to delete the data disks automatically when deleting the VM
    delete_data_disks_on_termination = true
  
  #  availability_set_id = azurerm_availability_set.example[count.index].id
  #  availability_set_id = azurerm_availability_set.example[count.index % 2].id
  availability_set_id = azurerm_availability_set.example[count.index].id

   storage_image_reference {
     publisher = "Canonical"
     offer     = "UbuntuServer"
     sku       = "16.04-LTS"
     version   = "latest"
   }

   storage_os_disk {
     name              = "myosdisk-${local.contents[count.index].name}${count.index}"
     caching           = "ReadWrite"
     create_option     = "FromImage"
     managed_disk_type = "Standard_LRS"
   }

   os_profile {
     computer_name  = "${local.contents[count.index].name}${count.index}"
     admin_username = "${local.contents[count.index].name}${count.index}"
     admin_password = var.adminPassw
   }  

   os_profile_linux_config {
     disable_password_authentication = false
   }

   tags = {
     environment = "staging"
   }

     

 # -----------------------------------------------------------------------
  provisioner "remote-exec"{
	inline = [
	# -S MOET MET GROTE LETTER S!!!
  "echo '${var.adminPassw}' | sudo -S apt-get update",
  "echo '${var.adminPassw}' | sudo -S apt-get upgrade",
	"echo '${var.adminPassw}' |sudo -S apt-get install -y nginx",
	"echo '${var.adminPassw}' |sudo -S systemctl start nginx",
	"echo '${var.adminPassw}' |sudo -S systemctl enable nginx",
	# Replace the default h1 tag with a custom message
	"echo '${var.adminPassw}' | sudo -S sed -i 's/Welcome to nginx/Welcome to webserver${count.index},  Hope u have a wonderful day <3/g' /var/www/html/index.nginx-debian.html",
  # Restart nginx to apply the changes
  "echo '${var.adminPassw}' |sudo -S systemctl restart nginx",
	]
  }
  connection {
    type        = "ssh"
    port        = "22"
    user        = "${local.contents[count.index].name}${count.index}"
    password    = var.adminPassw
    host        = azurerm_public_ip.pubIP[count.index].ip_address
  }


 }

 resource "azurerm_virtual_machine" "VMsWebserver2" {
   count                 = length(local.contents)
   name                  = "Webserver-${local.contents[count.index].name}-2"
   location              = local.contents[count.index].location
  #  availability_set_id   = azurerm_availability_set.avset[count.index].id
   resource_group_name   = local.contents[count.index].name
   network_interface_ids = [element(azurerm_network_interface.NIC1.*.id, count.index + 2)]
   vm_size               = "Standard_DS1_v2"

   # Uncomment this line to delete the OS disk automatically when deleting the VM
   delete_os_disk_on_termination = true

   # Uncomment this line to delete the data disks automatically when deleting the VM
    delete_data_disks_on_termination = true
  
  #  availability_set_id = azurerm_availability_set.example[count.index].id
  #  availability_set_id = azurerm_availability_set.example[count.index % 2].id
  availability_set_id = azurerm_availability_set.example[count.index].id

   storage_image_reference {
     publisher = "Canonical"
     offer     = "UbuntuServer"
     sku       = "16.04-LTS"
     version   = "latest"
   }

   storage_os_disk {
     name              = "myosdisk-${local.contents[count.index].name}${count.index + 2}"
     caching           = "ReadWrite"
     create_option     = "FromImage"
     managed_disk_type = "Standard_LRS"
   }

   os_profile {
     computer_name  = "${local.contents[count.index].name}${count.index}"
     admin_username = "${local.contents[count.index].name}${count.index}"
     admin_password = var.adminPassw
   }  

   os_profile_linux_config {
     disable_password_authentication = false
   }

   tags = {
     environment = "staging"
   }

     

 # -----------------------------------------------------------------------
  provisioner "remote-exec"{
	inline = [
	# -S MOET MET GROTE LETTER S!!!
  "echo '${var.adminPassw}' | sudo -S apt-get update",
  "echo '${var.adminPassw}' | sudo -S apt-get upgrade",
	"echo '${var.adminPassw}' |sudo -S apt-get install -y nginx",
	"echo '${var.adminPassw}' |sudo -S systemctl start nginx",
	"echo '${var.adminPassw}' |sudo -S systemctl enable nginx",
	# Replace the default h1 tag with a custom message
	"echo '${var.adminPassw}' | sudo -S sed -i 's/Welcome to nginx/Welcome to webserver${count.index + 2},  Hope u have a wonderful day <3/g' /var/www/html/index.nginx-debian.html",
  # Restart nginx to apply the changes
  "echo '${var.adminPassw}' |sudo -S systemctl restart nginx",
	]
  }
  connection {
    type        = "ssh"
    port        = "23"
    user        = "${local.contents[count.index].name}${count.index}"
    password    = var.adminPassw
    host        = azurerm_public_ip.pubIP[count.index].ip_address
  }



 }


# #source: https://developer.hashicorp.com/terraform/language/resources/provisioners/remote-exec
