resource "azurerm_key_vault_secret" "kombine-tls-cert" {
  name     = "kombine-tls-cert"
  value    = tls_self_signed_cert.kombine-tls-cert.cert_pem
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault_secret" "kombine-tls-key" {
  name     = "kombine-tls-key"
  value    = tls_private_key.kombine-tls-key.private_key_pem
  key_vault_id = azurerm_key_vault.keyvault.id
}