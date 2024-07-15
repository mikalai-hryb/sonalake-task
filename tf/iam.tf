###############################################################################
### IAM ECS Task Role
###############################################################################

data "aws_iam_policy_document" "ecs_task" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task" {
  name_prefix        = "${local.base_name}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task.json
}

###############################################################################
### IAM ECS Execution Role
###############################################################################

resource "aws_iam_role" "ecs_exec" {
  name_prefix        = "${local.base_name}-ecs-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_task.json
}

# pulls images from ECR
resource "aws_iam_role_policy_attachment" "ecs_exec_AmazonEC2ContainerServiceforEC2Role" {
  role       = aws_iam_role.ecs_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

###############################################################################
### IAM EC2 Role
###############################################################################

data "aws_iam_policy_document" "ec2" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name_prefix        = "${local.base_name}-ec2"
  assume_role_policy = data.aws_iam_policy_document.ec2.json
}

# creates CloudWatch log stream
resource "aws_iam_role_policy_attachment" "ec2_AmazonEC2ContainerServiceforEC2Role" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# manages SSM agent which allows AWS Console connection
resource "aws_iam_role_policy_attachment" "ssm_AmazonSSMFullAccess" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_instance_profile" "ec2" {
  name_prefix = "${local.base_name}-ec2"
  path        = "/ec2/instance/"
  role        = aws_iam_role.ec2.name
}
