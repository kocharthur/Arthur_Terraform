resource "aws_lb_target_group" "instance" {
  name     = "nginx"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  health_check {
    path = "/"
    port = 80
  }
}


resource "aws_lb" "load-balancer" {
  name               = "load-balancer"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.security-group.id]
  subnets            = [aws_subnet.private-subnet-a.id, aws_subnet.private-subnet-b.id, aws_subnet.private-subnet-c.id]
}


resource "aws_lb_listener" "nginx" {
  load_balancer_arn = aws_lb.load-balancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instance.arn
  }
}
resource "aws_lb_listener_rule" "nginx" {
  listener_arn = aws_lb_listener.nginx.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instance.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

resource "aws_lb_target_group_attachment" "default_attach" {
  target_group_arn = aws_lb_target_group.instance.arn
  target_id        = aws_instance.instance.id
  port             = 80
}

