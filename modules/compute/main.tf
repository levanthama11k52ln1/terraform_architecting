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


resource "aws_autoscaling_group" "three_tier_bastio" {
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

  user_data = EOF

  tags = {
    Name = "three-tier-app"
  }
}