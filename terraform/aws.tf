terraform {
  backend "s3" {
    region         = "eu-west-1"
    bucket         = "kabisa-terraform-statefiles"
    dynamodb_table = "kabisa-terraform-lockfiles"
    key            = "kudo-o-matic/terraform.tfstate"
    encrypt        = true

    assume_role = {
        role_arn = "arn:aws:iam::003476575487:role/admin"
    }
  }
}

provider "aws" {
  region = var.region

  assume_role {
    role_arn = "arn:aws:iam::${var.account_id}:role/admin"
  }
}