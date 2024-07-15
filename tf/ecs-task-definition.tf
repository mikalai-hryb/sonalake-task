resource "aws_ecs_task_definition" "this" {
  family             = "${aws_ecs_cluster.this.name}-${var.service_name}"
  task_role_arn      = aws_iam_role.ecs_task.arn
  execution_role_arn = aws_iam_role.ecs_exec.arn
  network_mode       = "bridge"
  cpu                = 256
  memory             = 64

  container_definitions = jsonencode([{
    name      = var.service_name,
    image     = docker_registry_image.this.name
    essential = true,
    portMappings = [{
      containerPort = local.container_port,
      hostPort      = local.container_port,
    }],
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        "awslogs-region"        = var.region,
        "awslogs-group"         = aws_cloudwatch_log_group.this.name,
        "awslogs-stream-prefix" = var.service_name
      }
    },
  }])
}