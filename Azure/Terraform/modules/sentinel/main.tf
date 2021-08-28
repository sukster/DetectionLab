provider "azurerm" {
    features {}
}

resource "azurerm_log_analytics_workspace" "detectionlab" {
    name = "detectionlab"
    location = var.region
    resource_group_name = var.resource_group_name
    sku = "PerGB2018"
    retention_in_days = 30
}

resource "azurerm_log_analytics_solution" "SecurityInsights" {
    solution_name = "SecurityInsights"
    location = var.region
    resource_group_name = var.resource_group_name
    workspace_resource_id = "${azurerm_log_analytics_workspace.detectionlab.id}"
    workspace_name = "${azurerm_log_analytics_workspace.detectionlab.name}"
    plan {
      publisher = "Microsoft"
      product = "OMSGallery/SecurityInsights"
    }
}

resource "azurerm_log_analytics_solution" "WindowsEventForwarding" {
    solution_name = "WindowsEventForwarding"
    location = var.region
    resource_group_name = var.resource_group_name
    workspace_resource_id = "${azurerm_log_analytics_workspace.detectionlab.id}"
    workspace_name = "${azurerm_log_analytics_workspace.detectionlab.name}"
    plan {
      publisher = "Microsoft"
      product = "OMSGallery/WindowsEventForwarding"
    }
}

resource "azurerm_virtual_machine_extension" "logger_omsagent" {
    name = "logger_omsagent"
    virtual_machine_id = var.logger_vm_id
    publisher = "Microsoft.EnterpriseCloud.Monitoring"
    type = "OmsAgentForLinux"
    type_handler_version = "1.9"
    auto_upgrade_minor_version = "true"
    settings = <<SETTINGS
      {
        "workspaceId": "${azurerm_log_analytics_workspace.detectionlab.workspace_id}"
      }
  SETTINGS
    protected_settings = <<PROTECTED_SETTINGS
    {
        "workspaceKey": "${azurerm_log_analytics_workspace.detectionlab.primary_shared_key}"
    }
  PROTECTED_SETTINGS
}

resource "azurerm_virtual_machine_extension" "wef_mmaagent" {
    name = "wef_mmaagent"
    virtual_machine_id = var.wef_vm_id
    publisher = "Microsoft.EnterpriseCloud.Monitoring"
    type = "MicrosoftMonitoringAgent"
    type_handler_version = "1.0"
    auto_upgrade_minor_version = "true"
    settings = <<SETTINGS
      {
        "workspaceId": "${azurerm_log_analytics_workspace.detectionlab.workspace_id}"
      }
  SETTINGS
    protected_settings = <<PROTECTED_SETTINGS
    {
        "workspaceKey": "${azurerm_log_analytics_workspace.detectionlab.primary_shared_key}"
    }
  PROTECTED_SETTINGS
}

resource "null_resource" "omsagent_config" {
    
  depends_on = [azurerm_virtual_machine_extension.logger_omsagent]

  provisioner "file" {
    source = "./modules/sentinel/files/conf"
    destination = "/home/vagrant"
    connection {
      host = var.logger_vm_public_ip
      user = "vagrant"
      private_key = file(var.private_key_path)
      type = "ssh"
    }
  }

  provisioner "remote-exec" {
    connection {
      host = var.logger_vm_public_ip
      user = "vagrant"
      private_key = file(var.private_key_path)
    }
    inline = [
      "sed -i 's/sentinel-workspace-id/${azurerm_log_analytics_workspace.detectionlab.workspace_id}/g' /home/vagrant/conf/*.conf",
      "sudo cp /home/vagrant/conf/*.conf /etc/opt/microsoft/omsagent/${azurerm_log_analytics_workspace.detectionlab.workspace_id}/conf/omsagent.d",
      "sudo chown -R omsagent:omiusers /etc/opt/microsoft/omsagent/${azurerm_log_analytics_workspace.detectionlab.workspace_id}/conf/omsagent.d",
      "sudo /opt/microsoft/omsagent/bin/service_control restart",
      "rm -Rf /home/vagrant/conf",
      "sudo /opt/splunk/bin/splunk stop",
      "sudo /opt/splunk/bin/splunk disable boot-start"
    ]
  }
}