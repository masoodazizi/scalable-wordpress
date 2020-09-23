resource "aws_launch_configuration" "lc" {
  key_name             = aws_key_pair.ssh_key.key_name
  name_prefix          = "${var.env}-wp-launch-configuration"
  image_id             = data.aws_ami.amazon-linux-2.id
  instance_type        = var.instance_type
  # iam_instance_profile = aws_iam_role.instance_role.name
  security_groups      = [aws_security_group.instance.id]
  user_data            = data.template_file.userdata.rendered

  root_block_device {
    volume_type = "gp2"
    volume_size = var.root_volume_size
  }

  lifecycle {
    create_before_destroy = true
  }
  # tags = "${merge(var.tags, map("Name", "${var.env}_ecs_lc"))}"
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.????????.?-x86_64-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

data "template_file" "userdata" {
  template = file("${path.module}/userdata.sh")

  vars = {
    wp_name = var.wp_name
    wp_init = var.wp_init
    wp_region = var.wp_region
    wp_efs_id = var.wp_efs_id
    wp_db_host = var.wp_db_host
    wp_db_name = var.wp_db_name
    wp_db_user = var.wp_init ? var.wp_db_user : ""
    wp_db_password = var.wp_init ? var.wp_db_password : ""
  }
}

resource "aws_autoscaling_group" "asg" {
  name                      = "${var.env}-wp-autoscaling-group"
  vpc_zone_identifier       = split(",", var.private_subnets)
  launch_configuration      = aws_launch_configuration.lc.name
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity
  health_check_grace_period = var.asg_health_check_grace_period
  health_check_type         = var.asg_health_check_type
  force_delete = true
  target_group_arns        = ["${aws_alb_target_group.tg.arn}"]

  tags = [
    {
      key                 = "Name"
      value               = "${var.env}-wp-instance"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = var.env
      propagate_at_launch = true
    },
    {
      key                 = "launch_configuration"
      value               = aws_launch_configuration.lc.name
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = var.tags["Project"]
      propagate_at_launch = true
    }
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "bastion" {
  count         = var.create_bastion ? 1 : 0
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t3.nano"
  key_name = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.bastion[0].id]
  associate_public_ip_address = true
  subnet_id = element(split(",", var.public_subnets),0)

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}-wp-bastion"
    },
  )
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.env}-wp-ssh-key"
  public_key = var.ssh_pub_key

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}-wp-ssh-key"
    },
  )
}
