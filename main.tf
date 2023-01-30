locals {
  config = var.config

  provision_kms = local.config.kms_arn == null ? 1 : 0
  kms_arn       = try(aws_kms_key.this[0].arn, local.config.kms_arn)
}

resource "random_password" "this" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
