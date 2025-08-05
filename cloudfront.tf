variable "nginx_elb_dns" {
  default = "a728f0b063a2540e8b2e5ad2575f38e3-2012861507.eu-central-1.elb.amazonaws.com"
}

module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "~> 5.0"

  comment             = "Nginx CloudFront"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  origin = {
    eks_nginx = {
      domain_name = var.nginx_elb_dns
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only" # LB only supports HTTP
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "eks_nginx"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values = {
      query_string = false
      cookies = {
        forward = "none"
      }
    }
  }

  geo_restriction = {
    restriction_type = "none"
  }

  viewer_certificate = {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "nginx-https-cloudfront"
  }

}
