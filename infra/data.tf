data "azuread_user" "admin" {
  user_principal_name = var.admin_upn
}