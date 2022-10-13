
# Get Certificate SSL (ACM)
data "aws_acm_certificate" "certificate_ssl" {

  domain   = "*.${var.domain_name}"
  statuses = ["ISSUED"]
}
