
# Get Certificate SSL (ACM)
data "aws_acm_certificate" "edtech_ssl" {

  domain   = "*.${var.domain_name}"
  statuses = ["ISSUED"]
}