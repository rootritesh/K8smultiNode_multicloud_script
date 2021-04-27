
//AWS CLOUD
provider "aws" {
  region = "ap-south-1"
}



resource "aws_instance"  "k8s_master_node_aws"  {
  ami           =  "ami-0eeb03e72075b9bcc"
  instance_type     =  "t2.medium"
  key_name          =  "key"
  subnet_id         = "subnet-3c574454"
  security_groups   = [ "sg-00c9eaec249d19d4b" ]



  tags  =  {
    Name  =  "AWS_k8s_master"
  }
}

resource "aws_instance"  "AWS_k8s_node1"  {
    
  ami           =  "ami-0eeb03e72075b9bcc"
  instance_type     =  "t2.medium"
  key_name          =  "key"
  subnet_id         = "subnet-3c574454"
  security_groups   = [ "sg-00c9eaec249d19d4b" ]



  tags  =  {
    Name  =  "AWS_k8s_node1"
  }
}



// Azure Cloud
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "res1" {
  name     = "esources1"
  location = "westus2"
}

resource "azurerm_virtual_network" "vn" {
  name                = "network1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.res1.location
  resource_group_name = azurerm_resource_group.res1.name
}

resource "azurerm_subnet" "sub" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.res1.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "publicip" {
  name                = "pip-vmterraform-dev-westus2-001"
  location            = "westus2"
  resource_group_name = azurerm_resource_group.res1.name
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "sgs" {
  name                = "azuresgs"
  location            = "westus2"
  resource_group_name = azurerm_resource_group.res1.name

  security_rule {
    name                       = "AllowAll"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "subnetassociate" {
  subnet_id                 = azurerm_subnet.sub.id
  network_security_group_id = azurerm_network_security_group.sgs.id
}

resource "azurerm_network_interface" "ni" {
  name                = "example-nic" 
  location            = azurerm_resource_group.res1.location
  resource_group_name = azurerm_resource_group.res1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

resource "azurerm_virtual_machine" "vm1" {
  name                  = "Az_k8s_node1"
  location              = azurerm_resource_group.res1.location
  resource_group_name   = azurerm_resource_group.res1.name
  network_interface_ids = [azurerm_network_interface.ni.id]
  vm_size               = "Standard_B2s"

  

  storage_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "8"
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
    admin_username = "manage"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "node1"
  }
}

