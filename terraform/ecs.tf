# -------------------------
# CloudWatch Log Group
# -------------------------
resource "aws_cloudwatch_log_group" "rag_logs" {
  name              = "/ecs/rag-service"
  retention_in_days = 7

  tags = {
    Name = "rag-service-logs"
  }
}

# -------------------------
# ECS Cluster
# -------------------------
resource "aws_ecs_cluster" "rag_cluster" {
  name = "rag-cluster"
}

# -------------------------
# ECS Task Definition
# -------------------------
resource "aws_ecs_task_definition" "rag_task" {
  family                   = "rag-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = var.existing_ecs_role_arn != "" ? var.existing_ecs_role_arn : aws_iam_role.ecs_task_execution_role[0].arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "${aws_ecr_repository.backend.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 18000
          protocol      = "tcp"
        }
      ]
      command = [
        "uvicorn", "main:app",
        "--host", "0.0.0.0",
        "--port", "18000",
        "--access-log"
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:18000/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.rag_logs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "backend"
        }
      }
    },
    {
      name      = "frontend"
      image     = "${aws_ecr_repository.frontend.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "NEXT_PUBLIC_API_URL"
          value = "http://${aws_lb.rag_alb.dns_name}:18000"
        }
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:3000/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.rag_logs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "frontend"
        }
      }
    }
  ])
}

# -------------------------
# ECS Service
# -------------------------
resource "aws_ecs_service" "rag_service" {
  name            = "rag-service"
  cluster         = aws_ecs_cluster.rag_cluster.id
  task_definition = aws_ecs_task_definition.rag_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = length(var.existing_subnet_ids) > 0 ? var.existing_subnet_ids : aws_subnet.rag_subnet[*].id
    assign_public_ip = true
    security_groups  = length(var.existing_sg_id) > 0 ? [var.existing_sg_id] : [aws_security_group.rag_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.rag_backend_tg.arn
    container_name   = "backend"
    container_port   = 18000
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.rag_frontend_tg.arn
    container_name   = "frontend"
    container_port   = 3000
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_cloudwatch_log_group.rag_logs,
    aws_lb_listener.rag_backend_listener,
    aws_lb_listener.rag_frontend_listener,
    aws_ecs_task_definition.rag_task
  ]
}
