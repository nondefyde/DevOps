module "gw_dep" {
  source = "modules/gw_dep"

  client      = var.app_project_prefix
  azr_region  = var.azr_region
  environment = var.environment
  stack       = var.stack
  tenant_id   = var.tenant_id
}


locals {
  base_name = "${var.stack}-${var.app_project_prefix}-${module.gw_dep.az_location_short}-${var.environment}"
}

module "appgw_v2" {
  source  = "claranet/app-gateway/azurerm"
  version = "7.4.2"

  stack               = var.stack
  environment         = var.environment
  location            = module.gw_dep.az_location
  location_short      = module.gw_dep.az_location_short
  client_name         = var.app_project_prefix
  resource_group_name = module.gw_dep.gw_resource_group_name

  virtual_network_name = module.gw_dep.virtual_network_name
  subnet_cidr          = "10.10.1.0/24"

  appgw_backend_http_settings = [{
    name                  = "${local.base_name}-backhttpsettings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 300
  }]

  appgw_backend_pools = [{
    name  = "${local.base_name}-backendpool"
    fqdns = ["example.com"]
  }]

  appgw_routings = [{
    name                       = "${local.base_name}-routing-https"
    rule_type                  = "Basic"
    http_listener_name         = "${local.base_name}-listener-https"
    backend_address_pool_name  = "${local.base_name}-backendpool"
    backend_http_settings_name = "${local.base_name}-backhttpsettings"
  }]

  custom_frontend_ip_configuration_name = "${local.base_name}-frontipconfig"

  appgw_http_listeners = [{
    name                           = "${local.base_name}-listener-https"
    frontend_ip_configuration_name = "${local.base_name}-frontipconfig"
    frontend_port_name             = "frontend-https-port"
    protocol                       = "Https"
    ssl_certificate_name           = "${local.base_name}-example-com-sslcert"
    require_sni                    = true
    host_name                      = "example.com"
    custom_error_configuration = [
      {
        custom_error_page_url = "https://example.com/custom_error_403_page.html"
        status_code           = "HttpStatus403"
      },
      {
        custom_error_page_url = "https://example.com/custom_error_502_page.html"
        status_code           = "HttpStatus502"
      }
    ]
  }]

  custom_error_configuration = [
    {
      custom_error_page_url = "https://example.com/custom_error_403_page.html"
      status_code           = "HttpStatus403"
    },
    {
      custom_error_page_url = "https://example.com/custom_error_502_page.html"
      status_code           = "HttpStatus502"
    }
  ]

  frontend_port_settings = [{
    name = "frontend-https-port"
    port = 443
  }]

  ssl_certificates_configs = [{
    name     = "${local.base_name}-example-com-sslcert"
    data     = var.certificate_example_com_filebase64
    password = var.certificate_example_com_password
  }]

  ssl_policy = {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20170401S"
  }

  appgw_url_path_map = [{
    name                               = "${local.base_name}-example-url-path-map"
    default_backend_http_settings_name = "${local.base_name}-backhttpsettings"
    default_backend_address_pool_name  = "${local.base_name}-backendpool"
    default_rewrite_rule_set_name      = "${local.base_name}-example-rewrite-rule-set"
    # default_redirect_configuration_name = "${local.base_name}-redirect"
    path_rules = [
      {
        name                       = "${local.base_name}-example-url-path-rule"
        backend_address_pool_name  = "${local.base_name}-backendpool"
        backend_http_settings_name = "${local.base_name}-backhttpsettings"
        rewrite_rule_set_name      = "${local.base_name}-example-rewrite-rule-set"
        paths                      = ["/demo/"]
      }
    ]
  }]

  autoscaling_parameters = {
    min_capacity = 2
    max_capacity = 15
  }

  logs_destinations_ids = [
    module.gw_dep.log_analytics_workspace_id,
    module.gw_dep.logs_storage_account_id,
  ]
}


