terraform {
  required_version = ">=1.3, <2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=6.0, <7.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">=5.0, <6.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
}

terraform {
  backend "s3" {}
}

moved {
  from = module.ecs-cluster
  to   = module.ecs_cluster
}

module "ecs_cluster" {
  source = "git@github.com:companieshouse/terraform-modules//aws/ecs/ecs-cluster?ref=1.0.428"

  stack_name                   = local.stack_name
  name_prefix                  = local.name_prefix
  environment                  = var.environment
  vpc_id                       = data.aws_vpc.vpc.id
  subnet_ids                   = local.application_subnet_ids
  ec2_key_pair_name            = var.ec2_key_pair_name
  ec2_instance_type            = var.ec2_instance_type
  ec2_image_id                 = var.ec2_image_id
  asg_max_instance_count       = var.asg_max_instance_count
  asg_min_instance_count       = var.asg_min_instance_count
  enable_container_insights    = var.enable_container_insights
  asg_desired_instance_count   = var.asg_desired_instance_count
  scaledown_schedule           = var.asg_scaledown_schedule
  scaleup_schedule             = var.asg_scaleup_schedule
  notify_topic_slack_endpoints = local.notify_topic_slack_endpoints

  default_tags = merge(
    module.iac_tags.tags,
    module.owner_tags.tags
  )
}

module "iac_tags" {
  source = "git@github.com:companieshouse/terraform-modules//aws/tagging/iac?ref=tags/1.0.428"

  group           = "infrastructure"
  source_code_url = "https://github.com/companieshouse/streaming-service-stack"
}

module "owner_tags" {
  source = "git@github.com:companieshouse/terraform-modules//aws/tagging/owner?ref=tags/1.0.428"

  platform_owner = "platform"
}
