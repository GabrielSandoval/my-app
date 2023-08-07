# # Error: creating Route 53 Record: InvalidInput: Invalid request: Expected exactly one of [AliasTarget, all of [TTL, and ResourceRecords], or TrafficPolicyInstanceId], but found none in Change with [Action=CREATE, Name=gsandoval.dev, Type=A, SetIdentifier=null]
# #  	status code: 400, request id: 04f2f21b-1b54-49de-bc9d-f42595112889
# #
# #  Error: creating Route 53 Record: InvalidInput: Invalid request: Expected exactly one of [AliasTarget, all of [TTL, and ResourceRecords], or TrafficPolicyInstanceId], but found none in Change with [Action=CREATE, Name=www.gsandoval.dev, Type=A, SetIdentifier=null]
# #  	status code: 400, request id: 5751de6a-b0c2-4458-97bd-57998c4a4b78
#
#
# resource "aws_route53_zone" "gsandoval-dev" {
#   name = "gsandoval.dev"
# }
#
# resource "aws_route53_record" "gsandoval-dev" {
#   zone_id = aws_route53_zone.gsandoval-dev.zone_id
#   name    = "gsandoval.dev"
#   type    = "A"
#
#   records = [aws_alb.my_app_load_balancer.dns_name]
# }
#
# resource "aws_route53_record" "www-gsandoval-dev" {
#   zone_id = aws_route53_zone.gsandoval-dev.zone_id
#   name    = "www.gsandoval.dev"
#   type    = "A"
#
#   records = [aws_alb.my_app_load_balancer.dns_name]
# }
