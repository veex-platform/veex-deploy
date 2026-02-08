provider "azurerm" {
  features {}
}

variable "location" { default = "East US" }
variable "vm_size" { default = "Standard_B2s" }

resource "azurerm_resource_group" "veex_rg" {
  name     = "veex-resources"
  location = var.location
}

resource "azurerm_virtual_network" "veex_vnet" {
  name                = "veex-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.veex_rg.location
  resource_group_name = azurerm_resource_group.veex_rg.name
}

resource "azurerm_subnet" "veex_subnet" {
  name                 = "veex-subnet"
  resource_group_name  = azurerm_resource_group.veex_rg.name
  virtual_network_name = azurerm_virtual_network.veex_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "veex_ip" {
  name                = "veex-ip"
  location            = azurerm_resource_group.veex_rg.location
  resource_group_name = azurerm_resource_group.veex_rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "veex_nic" {
  name                = "veex-nic"
  location            = azurerm_resource_group.veex_rg.location
  resource_group_name = azurerm_resource_group.veex_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.veex_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.veex_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "veex_vm" {
  name                = "veex-vm"
  resource_group_name = azurerm_resource_group.veex_rg.name
  location            = azurerm_resource_group.veex_rg.location
  size                = var.vm_size
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.veex_nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

output "public_ip" {
  value = azurerm_public_ip.veex_ip.ip_address
}
