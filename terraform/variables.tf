variable "ENVIRONMENT_NAME" {
  default = "covid-dev"
}
variable "SECONDARY_ENVIRONMENT_NAME" {
  default = "covid-staging"
}
variable "KOMBINE_RG_NAME" {
  default = "EsDCKombineRG"
}
variable "KOMBINE_DATA_RG_NAME" {
  default = "EsDCKombineRG_DATA"
}
variable "LOCATION" {
  default = "CanadaCentral"
}

variable "TERRAFORM_ENVIRONMENT_NAME"{
  default = "Sandbox"
}

variable "CLASSIFICATION" {
  default = "Unclassified"
}
variable "SUBSCRIPTION_ID" {}
variable "TENANT_ID" {}
variable "CLIENT_ID" {}
variable "CLIENT_SECRET" {}
variable "SSH_PUB" {}
variable "K8_AGENT_COUNT" {
  default = 4
}
variable "K8_AGENT_SIZE" {
  default = "Standard_D2_v2"
}
variable "K8_CLUSTER_SP_ID" {}
variable "K8_CLUSTER_SP_PASS" {}
variable "AKS_VERSION" {
  default = "1.14.8"
}

variable "VNET_ADDRESS_SPACE" {
  type    = list(string)
  default = ["10.100.0.0/22"]
}

variable "K8S_VNET_ADDRESS_PREFIX" {
  default = "10.100.1.0/24"
}
variable "K8_DNS_IP" {
  default = "10.100.3.10"
}
variable "K8_DOCKER_BRIDGE_CIDR" {
  default = "10.100.2.1/24"
}
variable "K8_SERVICE_CIDR" {
  default = "10.100.3.0/24"
}
variable "KEYVAULT_NAME" {
  default = "kombine-keyvault"
}
variable "KEYVAULT_NAME" {
  default = "kombine-keyvault"
}

