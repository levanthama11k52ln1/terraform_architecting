data "aws_ssm_parameter" "three_tier_ami" {
    name = "ssm-three-tier"
}

#launch template for bastion host


resource "aws_launch_template" "three_tier_bastion" {
  name_prefix   = "three-tier-bastion"
  instance_type = var.instance_type
  image_id = data.aws_ssm_parameter.three_tier_ami.value
  vpc_security_group_ids = [var.bastion_sg]
  key_name = var.key_name

  tags = {
    Name = "three-tier-bastion"
  }
}


resource "aws_autoscaling_group" "three_tier_bastion" {
    name = "three-tier-bastion"
    max_size = 1
    min_size = 1
    desired_capacity = 1
    vpc_zone_identifier = var.public_subnet
    
    launch_template {
        id = aws_launch_template.three_tier_bastion.id
        version = "$Latest"
    }
}



# launch template for frontend


resource "aws_launch_template" "three_tier_app" {
  name_prefix   = "three-tier-app"
  instance_type = var.instance_type
  image_id = data.aws_ssm_parameter.three_tier_ami.value
  vpc_security_group_ids = [var.frontend_app_sg]
  key_name = var.key_name

  user_data = filebase64("install_apache.sh")
  

  tags = {
    Name = "three-tier-app"
  }
}

data "aws_alb_target_group" "three_tier_tg" {
  name = var.lb_tg_name
}

resource "aws_autoscaling_group" "three_tier_app" {
    name = "three-tier-app"
    max_size = 3
    min_size = 2
    desired_capacity = 2
    vpc_zone_identifier = var.public_subnet

    target_group_arns = [data.aws_alb_target_group.three_tier_tg.arn]
    
    launch_template {
        id = aws_launch_template.three_tier_app.id
        version = "$Latest"
    }
}


# launch template for backend


resource "aws_launch_template" "three_tier_backend" {
  name_prefix   = "three-tier-backend"
  instance_type = var.instance_type
  image_id = data.aws_ssm_parameter.three_tier_ami.value
  vpc_security_group_ids = [var.backend_app_sg]
  key_name = var.key_name

  user_data = filebase64("install_node.sh")
  

  tags = {
    Name = "three-tier-backend"
  }
}


resource "aws_autoscaling_group" "three_tier_backend" {
    name = "three-tier-backend"
    max_size = 3
    min_size = 2
    desired_capacity = 2
    vpc_zone_identifier = var.private_subnet

    target_group_arns = [data.aws_alb_target_group.three_tier_tg.arn]
    
    launch_template {
        id = aws_launch_template.three_tier_backend.id
        version = "$Latest"
    }
}