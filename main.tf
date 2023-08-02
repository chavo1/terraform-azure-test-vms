locals {
  vms_count = toset(var.vms)
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.env_name}-rg" # Choose a unique name for your resource group
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.env_name}VirtualNetwork" # Choose a unique name for your virtual network
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.env_name}Subnet" # Choose a unique name for your subnet
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  for_each            = local.vms_count
  name                = "${var.env_name}PublicIP-${each.value}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_virtual_machine" "vm" {
  for_each = local.vms_count

  name                = "${var.env_name}VM-${each.value}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vm_size             = "Standard_DS1_v2"

  storage_os_disk {
    name              = "osdisk-${each.key}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  network_interface_ids            = [azurerm_network_interface.nic[each.value].id]
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  dynamic "storage_image_reference" {
    for_each = each.value == "vm1" ? [1] : [2] # Use different image for "vm1" (Ubuntu 22) and "vm2" & "vm3" (Red Hat)
    content {
      publisher = each.value == "vm1" ? "Canonical" : "RedHat"
      offer     = each.value == "vm1" ? "0001-com-ubuntu-server-focal" : "RHEL"
      sku       = each.value == "vm1" ? "20_04-lts-gen2" : "83-gen2"
      version   = each.value == "vm1" ? "20.04.202209200" : "latest"
    }
  }

  os_profile {
    computer_name  = "${var.env_name}VM-${each.value}"
    admin_username = "azureuser" # Change this to your desired admin username on azure VM
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys" # Change this to the desired path for authorized_keys on the azure machine
      key_data = file("~/.ssh/id_rsa.pub")              # Replace with your actual SSH public key on your local machine
    }
  }
}

resource "azurerm_network_interface" "nic" {
  for_each = local.vms_count

  name                = "${var.env_name}NIC-${each.value}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "rgNICConfig-${each.value}"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[each.value].id
  }
}