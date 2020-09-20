resource "aws_alb" "alb" {
  name            = "${var.env}-wp-alb"
  subnets         = split(",", var.public_subnets)
  security_groups = [aws_security_group.alb.id, aws_security_group.web_inbound.id]

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}_wp_alb"
    },
  )
}

resource "aws_alb_listener" "http_redirect" {
  count = var.enable_alb_https ? 1 : 0
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "http_forward" {
  count = var.enable_alb_https ? 0 : 1
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.tg.arn
  }
}

resource "aws_alb_listener" "https" {
  count = var.enable_alb_https ? 1 : 0
  load_balancer_arn = aws_alb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.tg.arn
  }
}

resource "aws_alb_target_group" "tg" {
  name        = "${var.env}-wp-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}_wp_tg"
    },
  )
}
