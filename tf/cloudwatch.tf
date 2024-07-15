resource "aws_cloudwatch_log_group" "this" {
  name = local.base_name
}