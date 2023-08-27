resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = local.alb_sg_ids
  subnets            = local.alb_subnet_ids

  enable_deletion_protection = false

}

resource "aws_lb_target_group" "example" {
  name        = "tf-example-lb-tg"
  port        = 9000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = local.vpc_id
}

resource "aws_lb_listener" "sonar" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}