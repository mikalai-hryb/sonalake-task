resource "aws_launch_template" "this" {
  name_prefix            = "${local.base_name}-"
  image_id               = data.aws_ssm_parameter.ecs_optimized_ami_id.value
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2.id]

  iam_instance_profile { arn = aws_iam_instance_profile.ec2.arn }
  monitoring { enabled = true }

  user_data = base64encode(<<-EOF
      #!/bin/bash
      echo ECS_CLUSTER=${aws_ecs_cluster.this.name} >> /etc/ecs/ecs.config;
    EOF
  )
}

resource "aws_autoscaling_group" "this" {
  name_prefix               = "${local.base_name}-"
  vpc_zone_identifier       = data.aws_subnets.this.ids
  min_size                  = 0
  max_size                  = 2
  desired_capacity          = 1
  health_check_grace_period = 60
  health_check_type         = "EC2"
  protect_from_scale_in     = false

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = local.base_name
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

resource "aws_ecs_capacity_provider" "this" {
  name = local.base_name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.this.arn
    managed_termination_protection = "DISABLED" # it turns on/off the instance scale-in protection for EC2 instances

    managed_scaling {
      maximum_scaling_step_size = 1
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = [aws_ecs_capacity_provider.this.name]

  default_capacity_provider_strategy {
    base              = 0   # The number of tasks, at a minimum, to run on the specified capacity provider
    weight            = 100 # The relative percentage of the total number of launched tasks that should use the specified capacity provider.
    capacity_provider = aws_ecs_capacity_provider.this.name
  }
}