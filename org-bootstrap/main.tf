/*
resource "aws_organizations_account" "tenant_env_accounts" {
  for_each = toset(var.envs)

  name  = "${var.tenant}-${each.key}"
  email = "aws+${var.tenant}-${each.key}@company.com"

  role_name = "OrganizationAccountAccessRole"

  tags = {
    Tenant = var.tenant
    Env    = each.key
  }
}
*/
