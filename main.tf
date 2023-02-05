locals {
  provision_kms = var.config.kms_arn == null ? 1 : 0
  kms_arn       = try(aws_kms_key.this[0].arn, var.config.kms_arn)
}

resource "random_password" "this" {
  length  = 24
  special = true
}
