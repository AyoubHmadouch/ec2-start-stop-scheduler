terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "start_ec2" {
  source = "./.."
  schedules = [
    {
      name                = "start_ec2"
      action              = "start"
      schedule            = "cron(0 22 * * ? *)" # cron(Minutes Hours Day-of-Month Month Day-of-Week Year)
      schedule_timezone   = "Europe/Paris"
      target_instance_ids = ["i-0ad36b9c97148e807", "i-0b7dec647c4dcc07b"]
      description         = "Start EC2 instances"
    },
    {
      name                = "stop_ec2"
      action              = "stop"
      schedule            = "cron(0 6 * * ? *)" # cron(Minutes Hours Day-of-Month Month Day-of-Week Year)
      schedule_timezone   = "Europe/Paris"
      target_instance_ids = ["i-0ad36b9c97148e807", "i-0b7dec647c4dcc07b"]
      description         = "Stop EC2 instances"
    }
  ]
}
