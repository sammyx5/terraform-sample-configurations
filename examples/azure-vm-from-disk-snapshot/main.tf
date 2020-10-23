# Create a resource group
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = "North Europe"
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

resource "azurerm_public_ip" "pip" {
  name                    = "${var.prefix}-pip"
  resource_group_name     = azurerm_resource_group.main.name
  location                = azurerm_resource_group.main.location
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    environment = "${var.prefix}-pip"
  }
}

resource "azurerm_network_security_group" "main" {
    name                = "${var.prefix}-nsg"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name

    security_rule {
        name                       = "RDP"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "${var.prefix}-nsg"
    }
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id 
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "main" {
    network_interface_id      = azurerm_network_interface.main.id
    network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_managed_disk" "os" {
  name                 = "${var.prefix}-os-disk"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Copy"
  source_resource_id   = var.osdisk_snap_id

  tags = {
    Disk = "OS Disk"
  }
}

resource "azurerm_managed_disk" "data" {
  name                 = "${var.prefix}-data-disk"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Copy"
  source_resource_id   = var.datadisk_snap_id

  tags = {
    Disk = "Data Disk"
  }
}


resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_D12_v2"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    name            = azurerm_managed_disk.os.name
    caching         = "ReadWrite"
    managed_disk_id = azurerm_managed_disk.os.id
    create_option   = "Attach"
    os_type         = "Windows"
  }
  storage_data_disk {
    name            = azurerm_managed_disk.data.name
    caching         = "ReadWrite"
    managed_disk_id = azurerm_managed_disk.data.id
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = 256
  }
  
  os_profile_windows_config {
    provision_vm_agent = false
    enable_automatic_upgrades = false
  }

  tags = {
    environment = "disks form disk snapshots"
  }
}

