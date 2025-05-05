output "jumpserver_ip" {
  value = azurerm_linux_virtual_machine.terraform_vm.public_ip_address
}

output "vm_username" {
  value = azurerm_linux_virtual_machine.terraform_vm.admin_username
}
