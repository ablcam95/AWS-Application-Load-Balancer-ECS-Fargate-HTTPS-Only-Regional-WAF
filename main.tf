# ALB + ECS Fargate + HTTPS only + WAFv2 attached.

resource "aws_lb" "alb" {
  name               = "max-lab-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-aaa", "subnet-bbb"]
  security_groups    = ["sg-aaa"]
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = "arn:aws:acm:us-east-1:111111111111:certificate/abc"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_listener" "redirect" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "tg" {
  name        = "max-lab-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "vpc-aaa"

  health_check {
    path                = "/health"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = "max-lab-cluster"
}

resource "aws_ecs_task_definition" "td" {
  family                   = "max-lab-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = "arn:aws:iam::111111111111:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([{
    name  = "app"
    image = "111111111111.dkr.ecr.us-east-1.amazonaws.com/app:latest"
    portMappings = [{ containerPort = 8080 }]
  }])
}

resource "aws_ecs_service" "svc" {
  name            = "max-lab-svc"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.td.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = ["subnet-aaa", "subnet-bbb"]
    security_groups = ["sg-bbb"]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "app"
    container_port   = 8080
  }
}

resource "aws_wafv2_web_acl" "acl" {
  name  = "max-lab-acl"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedCommon"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "common"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "max-lab-acl"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = aws_lb.alb.arn
  web_acl_arn  = aws_wafv2_web_acl.acl.arn
}
