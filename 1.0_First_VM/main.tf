
provider "azurerm" {
  features {
  }
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-${var.name}"
  location = var.location

}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name


  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"

  }

}

resource "azurerm_virtual_machine" "main" {

  name = "virtual-machine"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  network_interface_ids = ["${ azurerm_network_interface.main.id}"]
  vm_size               = "${"${var.environment}" == "dev" ?  var.vm_size_dev : var.vm_size_uat}"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  #Main Storage Disk
  storage_os_disk {
    # we can only have one unique disk  per VM
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  #adding additional external disk
  storage_data_disk {
    create_option = "Empty"
    lun = 1
    name = "additonal-data-disk-1"
    managed_disk_type = "Standard_LRS"
    disk_size_gb = 10

  }
  #adding more disk , change name and lun
  storage_data_disk {

    create_option = "Empty"
    lun = 2
    name = "additonal-data-disk-2"
    managed_disk_type = "StandardSSD_LRS"
    disk_size_gb = 10
  }



  os_profile {
    computer_name  = "nitinvm"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
    name = "virtual-machine"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.main.name}"
  }
}


#output defined here:
output "virual_machine_location" {
  value = "${azurerm_resource_group.main.*.location}"
}

output "virual_machine_name" {
  value = "${azurerm_virtual_machine.main.*.name}"
}

output "virual_machine_network_interface" {
  value = "${azurerm_virtual_network.main.*.name}"
}

output "azurerm_subnet" {
  value = "${azurerm_subnet.internal.*.name}"
}

