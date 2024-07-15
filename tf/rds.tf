resource "aws_db_instance" "this" {
  allocated_storage      = var.db.allocated_storage
  engine                 = var.db.engine
  engine_version         = var.db.engine_version
  identifier             = local.base_name
  instance_class         = var.db.instance_class
  parameter_group_name   = var.db.parameter_group_name
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.db.id]

  db_name  = var.db.name
  username = var.db.username
  password = var.db.password
  port     = var.db.port
}
