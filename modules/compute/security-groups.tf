resource "aws_security_group" "alb" {
  name        = "${var.env}-wp-alb-sg"
  description = "Controls traffic to/from ALB in the ${var.env} environment"
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}_wp_alb_sg"
    },
  )
}

resource "aws_security_group_rule" "alb_ingress_bastion" {
  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.bastion[0].id
}

resource "aws_security_group_rule" "alb_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group" "instance" {
  name        = "${var.env}-wp-instance-sg"
  description = "Controls traffic to/from instances in the ${var.env} environment"
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}_wp_instance_sg"
    },
  )
}

resource "aws_security_group_rule" "instance_ingress_alb" {
  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  security_group_id        = aws_security_group.instance.id
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "instance_ingress_bastion" {
  count     = var.create_bastion ? 1 : 0
  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  security_group_id        = aws_security_group.instance.id
  source_security_group_id = aws_security_group.bastion[0].id
}

resource "aws_security_group_rule" "aurora_ingress" {
  type      = "ingress"
  from_port = 3306
  to_port   = 3306
  protocol  = "tcp"

  security_group_id        = var.aurora_sg
  source_security_group_id = aws_security_group.instance.id
}

resource "aws_security_group_rule" "efs_ingress" {
  type      = "ingress"
  from_port = 2049
  to_port   = 2049
  protocol  = "tcp"

  security_group_id        = var.efs_sg
  source_security_group_id = aws_security_group.instance.id
}

resource "aws_security_group_rule" "instance_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.instance.id
}

resource "aws_security_group" "bastion" {
  count       = var.create_bastion ? 1 : 0
  name        = "${var.env}-bastion-sg"
  description = "Controls traffic to/from the bastion host in the ${var.env} environment"
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}_bastion_sg"
    },
  )
}

resource "aws_security_group_rule" "bastion_ingress_allowed_ips" {
  count       = var.create_bastion ? 1 : 0
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = var.access_cidrs

  security_group_id = aws_security_group.bastion[0].id
}

resource "aws_security_group_rule" "bastion_egress" {
  count       = var.create_bastion ? 1 : 0
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.bastion[0].id
}

######### WEB Inbound Security Group ##########

resource "aws_security_group" "web_inbound" {
  name        = "web-inbound-sg"
  description = "Allows traffic from port 80 and 443"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}_web_inbound_sg"
    },
  )
}

resource "aws_security_group_rule" "web_inbound_ingress_http" {
  type      = "ingress"
  from_port = "80"
  to_port   = "80"
  protocol  = "tcp"

  cidr_blocks = [
    "0.0.0.0/0",
  ]

  security_group_id = aws_security_group.web_inbound.id
}

resource "aws_security_group_rule" "web_inbound_ingress_https" {
  type      = "ingress"
  from_port = "443"
  to_port   = "443"
  protocol  = "tcp"

  cidr_blocks = [
    "0.0.0.0/0",
  ]

  security_group_id = aws_security_group.web_inbound.id
}

# resource "aws_security_group_rule" "bastion_ingress_maintenance" {
#   type      = "ingress"
#   from_port = 0
#   to_port   = 0
#   protocol  = "-1"
#
#   security_group_id        = aws_security_group.bastion.id
#   source_security_group_id = aws_security_group.maintenance.id
# }

########## MAINTENANCE SECURITY GROUP ##########

# resource "aws_security_group" "maintenance" {
#   name        = "${var.env}-maintenance-sg"
#   description = "Allows external access to the resources in the ${var.env} environment"
#   vpc_id      = var.vpc_id
#   tags = merge(
#     var.tags,
#     {
#       "Name" = "${var.env}_maintenance_sg"
#     },
#   )
# }
#
# resource "aws_security_group_rule" "maintenance_ingress_ips" {
#   type        = "ingress"
#   from_port   = 0
#   to_port     = 0
#   protocol    = "-1"
#   cidr_blocks = var.access_cidrs
#
#   security_group_id = aws_security_group.bastion.id
# }

# resource "aws_security_group_rule" "ecs_alb_egress" {
#   type        = "egress"
#   from_port   = 0
#   to_port     = 0
#   protocol    = "-1"
#   cidr_blocks = ["0.0.0.0/0"]
#
#   security_group_id = aws_security_group.bastion.id
# }
