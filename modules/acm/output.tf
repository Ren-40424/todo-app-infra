output "cf_cert_arn" {
  value = aws_acm_certificate.cf.arn
}

output "alb_cert_arn" {
  value = aws_acm_certificate.alb.arn
}
