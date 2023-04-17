module "website" {
  source = "../../"

  config = {
    domain_name = "example"

    firewall = {
      aws_managed_rules = {
        AWSManagedRulesAmazonIpReputationList = {},
        AWSManagedRulesCommonRuleSet = {
          rule_action_override = {
            SizeRestrictions_BODY = "allow"
          }
        }
      }
    }
  }
}
