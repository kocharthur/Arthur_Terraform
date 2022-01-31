resource "aws_launch_configuration" "nginx-launchconf" {
  image_id                    = data.aws_ami.amazon.id
  instance_type               = "t2.small"
  security_groups             = ["${aws_security_group.security-group.id}"]
  associate_public_ip_address = true
  key_name                    = "DevOps14"
  user_data                   = <<EOF
#!/bin/sh
sudo amazon-linux-extras enable epel
sudo yum install -y epel-release
sudo yum install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
EOF
}

resource "aws_autoscaling_group" "nginx-auto-scalling" {
  name                      = "aws_nginx"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  force_delete              = true
  launch_configuration      = aws_launch_configuration.nginx-launchconf.name
  vpc_zone_identifier       = [aws_subnet.private-subnet-a.id, aws_subnet.private-subnet-b.id, aws_subnet.private-subnet-c.id]
  tag {
    key                 = "Name"
    value               = "Nginx"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "nginx-policy" {
  name                   = "terraform-nginx"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.nginx-auto-scalling.name
}

resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_up" {
  alarm_name          = "web_cpu_alarm_up_1"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "75"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.nginx-auto-scalling.name
  }
  actions_enabled   = true
  alarm_actions     = [aws_autoscaling_policy.nginx-policy.arn]
  alarm_description = "This metric monitors ec2 cpu utilization"
}

resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_down" {
  alarm_name          = "web_cpu_alarm_down_1"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "20"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.nginx-auto-scalling.name 
  }
  actions_enabled   = true
  alarm_actions     = [aws_autoscaling_policy.nginx-policy.arn]
  alarm_description = "This metric monitors ec2 cpu utilization"
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.nginx-auto-scalling.id
  alb_target_group_arn   = aws_lb_target_group.instance.arn
}