resource "auth0_client" "auth_app" {
  name        = var.auth0_app_name
  app_type    = "non_interactive"
  grant_types = [
    "client_credentials"
  ]
}

resource "auth0_client_grant" "my_client_grant" {
  client_id = auth0_client.auth_app.id
  audience  = "${var.auth0_domain}/api/v2/"
  scope     = ["create:client_grants"]
}

resource "auth0_action" "claim_action" {
  name = "Add Custom Claim"
  supported_triggers {
    id = "credentials-exchange"
    version = "v2"
  }
  runtime = "node16"
  code = <<-EOT
    /**
    * Handler that will be called during the execution of a Client Credentials exchange.
    *
    * @param {Event} event - Details about client credentials grant request.
    * @param {CredentialsExchangeAPI} api - Interface whose methods can be used to change the behavior of client credentials grant.
    */
     exports.onExecuteCredentialsExchange = async (event, api) => {
      api.accessToken.setCustomClaim("https://m2m.sample.com/role", event.request.body.role);
     };
    EOT
  deploy = true
}

resource "auth0_trigger_binding" "m2m_flow" {
  trigger = "credentials-exchange"
  actions {
    id = auth0_action.claim_action.id
    display_name = auth0_action.claim_action.name
  }
}
