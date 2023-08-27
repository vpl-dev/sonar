resource "aws_cloudwatch_log_group" "sonar" {
  name              = "/ecs/sonar"
  retention_in_days = 7
}