## Remove the block comment to enable the creation of Azure Sentinel

module "sentinel" {
  source = "./modules/sentinel"
  resource_group_name = azurerm_resource_group.detectionlab.name
  region = var.region
  logger_vm_id = azurerm_virtual_machine.logger.id
  logger_vm_public_ip = azurerm_public_ip.logger-publicip-extzone.ip_address
  wef_vm_id = azurerm_virtual_machine.wef.id
  private_key_path = var.private_key_path
}