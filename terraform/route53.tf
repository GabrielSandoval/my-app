resource "aws_acm_certificate" "gabriel_dev" {
  domain_name       = "gsandoval.dev"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_zone" "gsandoval_dev" {
  name = "gsandoval.dev."
}

resource "aws_route53_record" "gsandoval_dev_alb" {
  zone_id = aws_route53_zone.gsandoval_dev.zone_id
  name    = "gsandoval.dev"
  type    = "A"

  alias {
    name                   = aws_alb.my_app_load_balancer.dns_name
    zone_id                = aws_alb.my_app_load_balancer.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_gsandoval_dev_alb" {
  zone_id = aws_route53_zone.gsandoval_dev.zone_id
  name    = "www.gsandoval.dev"
  type    = "A"

  alias {
    name                   = aws_alb.my_app_load_balancer.dns_name
    zone_id                = aws_alb.my_app_load_balancer.zone_id
    evaluate_target_health = false
  }
}

output "cert_arn" {
  value = aws_acm_certificate.gabriel_dev.arn
}
