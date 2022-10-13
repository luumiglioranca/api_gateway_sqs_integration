###########################################################################################################################################
#
# Provider - AWS
#
###########################################################################################################################################

provider "aws" {
  region  = "us-east-1"
  profile = ""

  assume_role {
    role_arn = ""
  }
}

terraform {
  backend "s3" {
    profile                     = ""
    bucket                      = ""
    key                         = ""
    region                      = "us-east-1"
    encrypt                     = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}

locals {

  account_id = ""
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
