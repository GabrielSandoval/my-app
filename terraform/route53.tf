resource "aws_route53_zone" "gsandoval_dev" {
  name = "gsandoval.dev."
}

resource "aws_acm_certificate" "gabriel_dev" {
  domain_name       = "gsandoval.dev"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "gabriel_dev_validation" {
  for_each = {
    for dvo in aws_acm_certificate.gabriel_dev.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = aws_route53_zone.gsandoval_dev.zone_id
}

resource "aws_acm_certificate_validation" "gabriel_dev_validation" {
  certificate_arn         = aws_acm_certificate.gabriel_dev.arn
  # validation_record_fqdns = [for record in aws_route53_record.gabriel_dev_validation : record.fqdn]
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
