terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_cloudwatch_log_group" "my_app" {
  name = "my_app"
}

data "dns_a_record_set" "alb_ips" {
  host = aws_alb.my_app_load_balancer.dns_name
}

output "app_public_ip" {
  value = data.dns_a_record_set.alb_ips
}

