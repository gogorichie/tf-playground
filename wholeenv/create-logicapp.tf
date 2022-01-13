resource "azurerm_logic_app_workflow" "logicappworkflow" {
  name                = "${azurerm_resource_group.rg.name}-logicapp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}


resource "azurerm_logic_app_trigger_http_request" "example" {
  name         = "some-http-trigger"
  logic_app_id = azurerm_logic_app_workflow.logicappworkflow.id

  schema = <<SCHEMA
{
    "type": "object",
    "properties": {
        "hello": {
            "type": "string"
        }
    }
}
SCHEMA

}

resource "azurerm_logic_app_action_custom" "example" {
  name         = "example-action"
  logic_app_id = azurerm_logic_app_workflow.logicappworkflow.id

  body = <<BODY
{
    "description": "A variable to configure the auto expiration age in days. Configured in negative number. Default is -30 (30 days old).",
    "inputs": {
        "variables": [
            {
                "name": "ExpirationAgeInDays",
                "type": "Integer",
                "value": -30
            }
        ]
    },
    "runAfter": {},
    "type": "InitializeVariable"
}
BODY

}

resource "azurerm_logic_app_action_custom" "example2" {
  name         = "example-action2"
  logic_app_id = azurerm_logic_app_workflow.logicappworkflow.id

  body = <<BODY
{
    "description": "A variable to configure the auto expiration age in days. Configured in negative number. Default is -30 (30 days old).",
    "inputs": {
        "variables": [
            {
                "name": "ExpirationAgeInDays2",
                "type": "Integer",
                "value": -30
            }
        ]
    },
    "runAfter": {},
    "type": "InitializeVariable"
}
BODY

}
