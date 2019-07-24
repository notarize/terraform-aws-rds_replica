###############################################################################
# Providers
###############################################################################
provider "aws" {
  version             = "~> 2.0"
  region              = var.region
  allowed_account_ids = [var.aws_account_id]
}

provider "aws" {
  region = "ap-southeast-2"
  alias  = "sydney"
}


provider "random" {
  version = "~> 2.0"
}

provider "template" {
  version = "~> 2.0"
}

terraform {
  required_version = ">= 0.12"
}


###############################################################################
# Other Resources
###############################################################################

data "aws_region" "current_region" {
}

module "vpc" {
  source   = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=tf_0.12-upgrade"
  vpc_name = "${var.environment}-${var.app_name}"
}

# https://www.terraform.io/docs/providers/aws/d/kms_secrets.html
data "aws_kms_secrets" "rds_credentials" {
  secret {
    name    = "password"
    payload = "AQICAHj9P8B8y7UnmuH+/93CxzvYyt+la85NUwzunlBhHYQwSAG+eG8tr978ncilIYv5lj1OAAAAaDBmBgkqhkiG9w0BBwagWTBXAgEAMFIGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMoasNhkaRwpAX9sglAgEQgCVOmIaSSj/tJgEE5BLBBkq6FYjYcUm6Dd09rGPFdLBihGLCrx5H"
  }
}

resource "aws_sns_topic" "my_test_sns" {
  name = "user-notification-topic"
}

data "aws_kms_alias" "rds_crr" {
  provider = "aws.sydney"
  name     = "alias/aws/rds"
}

module "vpc_dr" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=tf_0.12-upgrade"

  providers = {
    aws = "aws.sydney"
  }

  vpc_name = "${var.environment}-${var.app_name}-DR"
}
