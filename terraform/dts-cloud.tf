terraform {
  backend "azurerm" {
    resource_group_name = "EsDCKombineRG"
    storage_account_name  = "dtskombinestorage"
    container_name        = "kombinetfstate"
    key                   = "terraform.tfstate"
  }
}

provider "azurerm" {
  version = "~> 2.0.0"
  features {}
  subscription_id = var.SUBSCRIPTION_ID
  tenant_id = var.TENANT_ID
  client_id = var.CLIENT_ID
  client_secret = var.CLIENT_SECRET
}

resource "azurerm_resource_group" "main" {
  name     = var.KOMBINE_RG_NAME
  location = var.LOCATION
  tags = {
    Environment = var.TERRAFORM_ENVIRONMENT_NAME
    Terraform = "True"
    Branch = "IITB"
    Classification = var.CLASSIFICATION
    Directorate = "BSIM"
    Project = "DTS"
  }
}

resource "azurerm_resource_group" "data" {
  name     = var.KOMBINE_DATA_RG_NAME
  location = azurerm_resource_group.main.location
  tags = {
    Environment = var.TERRAFORM_ENVIRONMENT_NAME
    Terraform = "True"
    Branch = "IITB"
    Classification = var.CLASSIFICATION
    Directorate = "BSIM"
    Project = "DTS"
  }
}

resource "azurerm_virtual_network" "k8svnet" {
  name                = azurerm_resource_group.main.name
  address_space       = var.VNET_ADDRESS_SPACE
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = {
    environment = var.TERRAFORM_ENVIRONMENT_NAME
    Terraform = "True"
    Branch = "IITB"
    Classification = var.CLASSIFICATION
    Directorate = "BSIM"
    Project = "DTS"
  }
}
resource "azurerm_subnet" "k8sVMSubnet" {
  name                 = "k8s-vm-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.k8svnet.name
  address_prefix = var.K8S_VNET_ADDRESS_PREFIX

}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${azurerm_resource_group.main.name}-K8S"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = azurerm_resource_group.main.name
  api_server_authorized_ip_ranges = []
  enable_pod_security_policy = false


  role_based_access_control {
    enabled         = "true"
  }

  default_node_pool {
    name       = "default"
    node_count = var.K8_AGENT_COUNT
    vm_size    = var.K8_AGENT_SIZE
    os_disk_size_gb = 60
    vnet_subnet_id  = azurerm_subnet.k8sVMSubnet.id
    availability_zones = []
    enable_auto_scaling = false
    enable_node_public_ip = false
    node_taints = []

  }
    linux_profile {
        admin_username  = "dtsadmin"
        ssh_key {
          key_data = var.SSH_PUB
        }
    }  

#    windows_profile {
#          admin_username = "azureuser" 
#    }

    network_profile {
      network_plugin = "azure"
      dns_service_ip = var.K8_DNS_IP
      docker_bridge_cidr = var.K8_DOCKER_BRIDGE_CIDR
      service_cidr = var.K8_SERVICE_CIDR

    }

  service_principal {
    client_id     = var.K8_CLUSTER_SP_ID
    client_secret = var.K8_CLUSTER_SP_PASS
  }

  tags = {
    Environment = var.TERRAFORM_ENVIRONMENT_NAME
    Terraform = "True"
    Branch = "IITB"
    Classification = var.CLASSIFICATION
    Directorate = "BSIM"
    Project = "DTS"
  }
}

resource "azurerm_key_vault" "keyvault" {
  name                        = "${var.KEYVAULT_NAME}-${var.TERRAFORM_ENVIRONMENT_NAME}"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  enabled_for_disk_encryption = true
  tenant_id                   = var.TENANT_ID

 sku_name = "standard"

  tags = {
    environment = var.TERRAFORM_ENVIRONMENT_NAME
    Terraform = "True"
    Branch = "IITB"
   Classification = var.CLASSIFICATION
    Directorate = "BSIM"
    Project = "DTS"
  }
}

resource "azurerm_storage_account" "dtskombinestorage" {
  name                     = var.KOMBINE_STORAGE_ACCOUNT
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.TERRAFORM_ENVIRONMENT_NAME
  }
}

resource "azurerm_storage_share" "dtskombinefileshare" {
  name                 = var.KOMBINE_FILE_SHARE
  storage_account_name = azurerm_storage_account.dtskombinestorage.name
  quota                = 50
}

resource "azurerm_storage_container" "kombinetfstate" {
  name                  = "kombinetfstate"
  storage_account_name  = azurerm_storage_account.dtskombinestorage.name
  container_access_type = "private"
}