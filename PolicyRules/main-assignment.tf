data "template_file" "requiredTag_policy_rule" {
  template = <<POLICY_RULE
{
    "if": {
        "field": "[concat('tags[', parameters('tagName'), ']')]",
        "exists": "false"
    },
    "then": {
        "effect": "audit"
    }
}
POLICY_RULE
}

data "template_file" "requiredTag_policy_parameters" {
  template = <<PARAMETERS
{
    "tagName": {
        "type": "String",
        "metadata": {
            "displayName": "Tag Name",
            "description": "Name of the tag, such as 'environment'"
        }
    }
}
PARAMETERS
}

resource "azurerm_policy_definition" "requiredTag" {
  name         = "Audit-RequiredTag-Resource"
  display_name = "Audit a Required Tag on a Resource"
  description  = "Audit all resources for a required tag"
  policy_type  = "Custom"
  mode         = "All"
  policy_rule  = "${data.template_file.requiredTag_policy_rule.rendered}"
  parameters   = "${data.template_file.requiredTag_policy_parameters.rendered}"
}

data "azurerm_subscription" "current" {}

variable "requiredTag" {
  default = "Environment"
}

data "template_file" "requiredTag_policy_assign" {
  template = <<PARAMETERS
{
    "tagName": {
        "value": "${var.requiredTag}"
    }
}

PARAMETERS
}

resource "azurerm_policy_assignment" "requiredTag" {
  name                 = "Audit-RequiredTag-${var.requiredTag}"
  display_name         = "Assign Required Tag '${var.requiredTag}'"
  description          = "Assignment of Required Tag Policy for '${var.requiredTag}'"
  policy_definition_id = "${azurerm_policy_definition.requiredTag.id}"
  scope                = "${data.azurerm_subscription.current.id}"
  parameters           = "${data.template_file.requiredTag_policy_assign.rendered}"
}