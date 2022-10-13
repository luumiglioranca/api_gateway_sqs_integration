###########################################################################################################################################
#
# Provider - AWS
#
###########################################################################################################################################

provider "aws" {
  region  = "us-east-1"
  profile = "ops-payer"

  assume_role {
    role_arn = "arn:aws:iam::${local.account_id}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias   = "atena"
  region  = "us-east-1"
  profile = "atena"

}

terraform {
  backend "s3" {
    profile                     = "ops-payer"
    bucket                      = "s3-compasso-uol-424747098912-tfstate"
    key                         = ""
    region                      = "us-east-1"
    encrypt                     = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}

locals {

  account_id = "057422990009"
}

module "api_gateway_integration_sqs" {

  source                  =   ""
							  
  region                  =   ""
  account_id              =   ""
  vpc_id                  =   ""
  subnet_priv_1a          =   ""
  subnet_priv_1b          =   ""
  domain_name             =   ""
  task_role_arn_publisher =   ""
  task_role_arn_consumer  =   ""
  queue_name              =   ""
  api_domain_name         =   ""
  ssl                     =   ""
  endpoint_configuration  =   ""

}
