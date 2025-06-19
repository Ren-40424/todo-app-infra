data "aws_ssm_parameter" "google_client_id" {
  name = "/${var.project_name}/${var.environment}/oauth/google/client_id"
}

data "aws_ssm_parameter" "google_client_secret" {
  name            = "/${var.project_name}/${var.environment}/oauth/google/client_secret"
  with_decryption = true
}

resource "aws_cognito_user_pool" "this" {
  name = "${var.project_name}-pool"

  alias_attributes         = ["email"]
  auto_verified_attributes = ["email"]

  deletion_protection = "ACTIVE"

  user_pool_tier = "ESSENTIALS"

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }

    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }
}

resource "aws_cognito_user_pool_client" "this" {
  name         = "${var.project_name}-client"
  user_pool_id = aws_cognito_user_pool.this.id

  supported_identity_providers         = ["COGNITO", "Google"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email"]

  access_token_validity  = 60
  auth_session_validity  = 3
  id_token_validity      = 60
  refresh_token_validity = 5

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  callback_urls = ["https://app.${var.domain_name}/callback"]
  logout_urls   = ["https://app.${var.domain_name}"]
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = "${var.project_name}-practice"
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = aws_cognito_user_pool.this.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    attributes_url                = "https://people.googleapis.com/v1/people/me?personFields="
    attributes_url_add_attributes = true
    client_id                     = data.aws_ssm_parameter.google_client_id.value
    client_secret                 = data.aws_ssm_parameter.google_client_secret.value
    authorize_url                 = "https://accounts.google.com/o/oauth2/v2/auth"
    authorize_scopes              = "openid email profile"
    oidc_issuer                   = "https://accounts.google.com"
    token_request_method          = "POST"
    token_url                     = "https://www.googleapis.com/oauth2/v4/token"
  }

  attribute_mapping = {
    username = "sub"
    email    = "email"
  }
}
