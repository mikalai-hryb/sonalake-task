resource "aws_security_group" "lb" {
  name_prefix = "lb-sg-"
  description = "Security group for Load Balancer"
  vpc_id      = local.vpc_id

  ingress {
    protocol  = "tcp"
    from_port = var.app.port
    to_port   = var.app.port
    cidr_blocks = concat(
      ["${local.my_ip}/32"],
      var.app.ingress_cidr_blocks,
    )
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "lb_ec2_access" {
  security_group_id = aws_security_group.ec2.id

  description              = "Allow LB to connect to EC2 instances"
  type                     = "ingress"
  source_security_group_id = aws_security_group.lb.id
  from_port                = local.container_port
  to_port                  = local.container_port
  protocol                 = "tcp"
}

resource "aws_security_group" "ec2" {
  name_prefix = "ec2-sg-"
  description = "Security group for EC2 instances"
  vpc_id      = local.vpc_id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db" {
  name_prefix = "db-sg-"
  description = "Security group for RDS database"
  vpc_id      = local.vpc_id
}

resource "aws_security_group_rule" "ec2_db_access" {
  security_group_id = aws_security_group.db.id

  description              = "Allow EC2 instances to connect to RDS database"
  type                     = "ingress"
  source_security_group_id = aws_security_group.ec2.id
  from_port                = var.db.port
  to_port                  = var.db.port
  protocol                 = "tcp"
}
