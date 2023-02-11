data "azurerm_resource_group" "rg" {
  name = var.group
}

data "azurerm_api_management" "apim" {
  name                = "${var.prefix}-api"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_api_management_api" "apimp" {
  name                  = "${var.prefix}-${var.name}-http-api"
  resource_group_name   = data.azurerm_resource_group.rg.name
  api_management_name   = data.azurerm_api_management.apim.name
  revision              = var.revision
  display_name          = var.display_name
  path                  = var.suffix
  protocols             = var.protocols
  subscription_required = false
}

resource "azurerm_api_management_api_operation" "apimp_operations" {
  count               = length(var.methods)
  operation_id        = "${var.prefix}-${var.name}-operation-${count.index}"
  api_name            = azurerm_api_management_api.apimp.name
  api_management_name = data.azurerm_api_management.apim.name
  resource_group_name = data.azurerm_resource_group.rg.name
  display_name        = "${var.methods[count.index]} Resource"
  method              = var.methods[count.index]
  url_template        = var.endpoints

  request {
    header {
      name     = var.header
      type     = "string"
      required = true
    }
  }
}

resource "azurerm_api_management_api_operation_policy" "api_operation_policy" {
  count               = length(var.methods)
  api_name            = azurerm_api_management_api.apimp.name
  api_management_name = data.azurerm_api_management.apim.name
  resource_group_name = data.azurerm_resource_group.rg.name
  operation_id        = azurerm_api_management_api_operation.apimp_operations[count.index].operation_id

  xml_content = <<XML
<policies>
    <inbound>
        <set-variable name="base64EncodedValue" value="@(context.Request.Headers.GetValueOrDefault("x-api-key", ""))" />
        <set-variable name="decodedValue" value="@{
                try{
                    var base64EncodedBytes = System.Convert.FromBase64String(context.Variables
                    .GetValueOrDefault<string>("base64EncodedValue"));
                    return System.Text.Encoding.UTF8.GetString(base64EncodedBytes);
                 } catch(Exception e) {return null;}
            }" />
        <set-variable name="user_id" value="@{
            try{
                string[] stringSeparators = new string[] { ":" };
                var splitDecodedValue = context.Variables.GetValueOrDefault<string>("decodedValue")
                .Split(stringSeparators, 5, StringSplitOptions.None);
                return splitDecodedValue[2];
            } catch(Exception e) {return null;}
        }" />
        <set-variable name="tenant_id" value="@{
            try{
                string[] stringSeparators = new string[] { ":" };
                var splitDecodedValue = context.Variables.GetValueOrDefault<string>("decodedValue")
                .Split(stringSeparators, 5, StringSplitOptions.None);
                return splitDecodedValue[4];
            } catch(Exception e) {return null;}
        }" />
        <choose>
            <when condition="@(String.IsNullOrEmpty(context.Variables.GetValueOrDefault<string>("user_id")))">
                <return-response>
                    <set-status code="400" reason="Bad Request" />
                    <set-body>The authentication value is currently invalid</set-body>
                </return-response>
            </when>
            <otherwise>
                <set-header name="x-user-id" exists-action="append">
                    <value>@(context.Variables.GetValueOrDefault<string>("user_id"))</value>
                </set-header>
                <set-header name="x-tenant-id" exists-action="append">
                    <value>@(context.Variables.GetValueOrDefault<string>("tenant_id"))</value>
                </set-header>
            </otherwise>
        </choose>
    </inbound>
    <backend>
        <forward-request />
    </backend>
    <outbound />
    <on-error>
        <set-header name="ErrorSource" exists-action="append">
            <value>@(context.LastError.Source)</value>
        </set-header>
        <set-header name="ErrorReason" exists-action="append">
            <value>@(context.LastError.Reason)</value>
        </set-header>
        <set-header name="ErrorMessage" exists-action="append">
            <value>@(context.LastError.Message)</value>
        </set-header>
        <set-header name="ErrorStatusCode" exists-action="append">
            <value>@(context.Response.StatusCode.ToString())</value>
        </set-header>
    </on-error>
</policies>
XML

}