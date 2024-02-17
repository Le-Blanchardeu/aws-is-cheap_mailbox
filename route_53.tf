data "aws_route53_zone" "website_domain" {
  name = "${var.domain_name}."
}

resource "aws_route53_record" "mx_record" {
  zone_id = data.aws_route53_zone.website_domain.zone_id
  name    = var.domain_name
  type    = "MX"
  ttl     = 300
  records = ["10 inbound-smtp.eu-west-1.amazonaws.com"]
}