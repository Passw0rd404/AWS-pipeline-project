provider "aws" {
  region = "eu-north-1"
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

module "vpc" {
  source            = "../infrastructure-modules/vpc"
  vpc          = "10.0.0.0/16"
  pub_1 = "10.0.0.0/24"
  pub_2 = "10.0.1.0/24"
  region            = "eu-north-1"
  env               = "dev"
}

module "ec2" {
  source            = "../infrastructure-modules/ec2"
  region            = "eu-north-1"
  env               = "dev"
  key_name          = "aws-hero"
  instance_type     = "t3.micro"
  min_size          = 2
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = [module.vpc.pub_1_id, module.vpc.pub_2_id]
  subnet_ids        = [module.vpc.pub_1_id, module.vpc.pub_2_id]
  security_group_id = module.vpc.security_group_id
  depends_on = [ module.vpc ]
}

module "code-pipeline" {
  source                  = "../infrastructure-modules/code-pipeline"
  region                  = "eu-north-1"
  env                     = "dev"
  auto_scaling_group_name = module.ec2.auto_scaling_group_name
  github_repo             = "srv-02"
  github_owner            = "Passw0rd404"
  github_branch = "main"
#  tg_name = module.ec2.tg_name
  depends_on = [ module.ec2 ]
}