resource "azurerm_virtual_network" "vpc" {
 name = "${var.project}-network"
 address_space = ["10.0.0.0/16"]
 location = var.location
 resource_group_name = "devops-jayseeli"
 tags = {
    CostCenter = "71009503"
    OpexID =  "901950317"
    CostCenterOwner = "David Luft"
    ApplicationOwner = "Jayseeli Arputhasamy"
  }
}
resource "azurerm_subnet" "subnet-1" {
 name = "internal"
 resource_group_name = "devops-jayseeli"
 virtual_network_name = azurerm_virtual_network.vpc.name
 address_prefixes = ["10.0.1.0/24"]
}
resource "azurerm_subnet" "AzureFirewallSubnet" {
 name = "AzureFirewallSubnet" # mandatory name -do not rename-
 address_prefixes = ["10.0.2.0/26"]
 virtual_network_name = azurerm_virtual_network.vpc.name
 resource_group_name = "devops-jayseeli"
}
resource "azurerm_public_ip" "example" {
  name                = "testpip"
  location            = var.location
  resource_group_name = "devops-jayseeli"
  allocation_method   = "Static"
  sku                 = "Standard"
}
resource "azurerm_firewall" "firewall" {
 name = "${var.project}-firewall"
 resource_group_name = "devops-jayseeli"
 location = var.location
 sku_name = "AZFW_VNet"
 sku_tier = "Standard"
 tags = {
    CostCenter = "71009503"
    OpexID =  "901950317"
    CostCenterOwner = "David Luft"
    ApplicationOwner = "Jayseeli Arputhasamy"
  }
 ip_configuration {
 name = "${var.location}-azure-firewall-config"
 subnet_id = azurerm_subnet.AzureFirewallSubnet.id
 public_ip_address_id = azurerm_public_ip.example.id
 }
}
resource "azurerm_firewall_network_rule_collection" "allow-web" {
 name = "azure-firewall-web-rule"
 azure_firewall_name = azurerm_firewall.firewall.name
 resource_group_name = "devops-jayseeli"
 priority = 101
 action = "Allow"
 rule {
 name = "HTTP"
 source_addresses = ["0.0.0.0/0"]
 destination_ports = ["80"]
 destination_addresses = ["*"]
 protocols = ["TCP"] 
 }
 # Any number of rules can be added
}
