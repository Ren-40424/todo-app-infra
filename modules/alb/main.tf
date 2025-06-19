resource "aws_lb" "this" {
  subnets            = toset(values(var.subnet_ids))
  load_balancer_type = "application"
  internal           = false
  security_groups    = [module.sg.id]

  tags = {
    Name = "${var.project_name}-alb"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = {
    Name = "${var.project_name}-http-listener"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
  tags = {
    Name = "${var.project_name}-https-listener"
  }
}

resource "aws_lb_target_group" "this" {
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = var.health_check_matcher
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = { for k, id in var.instance_ids : k => id }

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = each.value
  port             = 3000
}

resource "aws_route53_record" "app-origin" {
  zone_id = var.route53_zone_id
  name    = "api-origin.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = false
  }
}

module "sg" {
  source       = "../security_group"
  project_name = var.project_name
  vpc_id       = var.vpc_id

  rule_map = {
    allow_http_from_all = {
      type                     = "ingress"
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      cidr_blocks              = ["0.0.0.0/0"]
      source_security_group_id = null
    }

    allow_https_from_all = {
      type                     = "ingress"
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      cidr_blocks              = ["0.0.0.0/0"]
      source_security_group_id = null
    }

    allow_http_to_ec2 = {
      type                     = "egress"
      from_port                = 3000
      to_port                  = 3000
      protocol                 = "tcp"
      cidr_blocks              = null
      source_security_group_id = var.ec2_sg_id
    }
  }
}
