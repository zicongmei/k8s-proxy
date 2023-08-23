
# Create public IPs
resource "azurerm_public_ip" "test" {
  name                         = "${local.name}-ip"
  location                     = local.region
  resource_group_name          = azurerm_resource_group.rg.name
  public_ip_address_allocation = "dynamic"
}

# create a network interface
resource "azurerm_network_interface" "test" {
  name                = "${local.name}-nic"
  location                     = local.region
  resource_group_name          = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${local.name}-ip-conf"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.test.id}"
  }
}

# Create virtual machine
resource "azurerm_virtual_machine" "test" {
  name                  = "${local.name}-vm"
  location                     = local.region
  resource_group_name          = azurerm_resource_group.rg.name
  network_interface_ids = ["${azurerm_network_interface.test.id}"]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "22.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = var.username
    admin_password = var.password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

}