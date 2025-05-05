resource "azurerm_public_ip" "jumpserver_public_ip" {
  name                = var.vm_public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = var.vm_ip_allocation_method
}

resource "azurerm_network_security_group" "vm_nsg" {
  name                = var.vm_nsg_name
  resource_group_name = var.resource_group_name
  location            = var.location

  dynamic "security_rule" {
    for_each = var.vm_security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_network_interface" "vm_nic" {
  name                = var.vm_nic_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = var.vm_nic_configuration_name
    subnet_id                     = var.vm_subnet_id
    private_ip_address_allocation = var.vm_nic_private_ip_allocation_method
    public_ip_address_id          = azurerm_public_ip.jumpserver_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsgconnection" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

resource "azurerm_linux_virtual_machine" "terraform_vm" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.vm_nic.id]
  size                  = var.vm_size

  os_disk {
    name                 = var.vm_os_disk_name
    caching              = "ReadWrite"
    storage_account_type = var.vm_osdisk_storage_account_type
  }

  source_image_reference {
    publisher = var.vm_image_publisher_name
    offer     = var.vm_image_offer_name
    sku       = var.vm_image_sku_name
    version   = var.vm_image_version_name
  }

  computer_name                   = var.vm_name
  admin_username                  = var.vm_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.vm_username
    public_key = var.public_ssh_key
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.public_ip_address
      user        = var.vm_username
      private_key = file("~/.ssh/id_rsa")
    }
    script = "${path.module}/scripts/install.sh"
  }
}


# This block is only for active testing of provisioner without touching the vm
# not recommended for actual use with vm module

# resource "time_static" "state_refresh" {
#   triggers = {
#     timestamp = timestamp()
#   }
# }

# resource "null_resource" "remote_exec" {
#   triggers = {
#     always_run = time_static.state_refresh.id
#   }
#   provisioner "remote-exec" {
#     connection {
#       type        = "ssh"
#       host        = azurerm_public_ip.jumpserver_public_ip.ip_address
#       user        = var.vm_username
#       private_key = file("~/.ssh/id_rsa")
#     }
#     script = "${path.module}/scripts/install.sh"
#   }

#   depends_on = [azurerm_linux_virtual_machine.terraform_vm]
# }
