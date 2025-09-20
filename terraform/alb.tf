# -------------------------
# Generate random suffix for SG name if new SG is created
# -------------------------
resource "random_string" "alb_sg_suffix" {
  length  = 5
  special = false
}

# -------------------------
# Security Group for ALB (conditional creation with unique name)
# -------------------------
resource "aws_security_group" "rag_alb_sg" {
  count  = var.existing_alb_sg_id == "" ? 1 : 0
  name   = "rag-alb-sg-${random_string.alb_sg_suffix.result}"
  vpc_id = aws_vpc.rag_vpc.id

  description = "Allow inbound traffic for frontend and backend"

  # Frontend HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Backend HTTP
  ingress {
    from_port   = 18000
    to_port     = 18000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound to ECS tasks and internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rag-alb-sg"
  }
}

# -------------------------
# Local variable to reference SG
# -------------------------
locals {
  alb_sg_id = var.existing_alb_sg_id != "" ? var.existing_alb_sg_id : aws_security_group.rag_alb_sg[0].id
}

# -------------------------
# Application Load Balancer
# -------------------------
resource "aws_lb" "rag_alb" {
  name               = "rag-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [local.alb_sg_id]
  subnets            = length(var.existing_subnet_ids) > 0 ? var.existing_subnet_ids : aws_subnet.rag_subnet[*].id

  tags = {
    Name = "rag-alb"
  }
}

# -------------------------
# Target Group for Backend
# -------------------------
resource "aws_lb_target_group" "rag_backend_tg" {
  name        = "rag-backend-tg"
  port        = 18000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.rag_vpc.id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "rag-backend-tg"
  }
}

# -------------------------
# Target Group for Frontend
# -------------------------
resource "aws_lb_target_group" "rag_frontend_tg" {
  name        = "rag-frontend-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.rag_vpc.id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "rag-frontend-tg"
  }
}

# -------------------------
# Listener for Frontend (Port 80)
# -------------------------
resource "aws_lb_listener" "rag_frontend_listener" {
  load_balancer_arn = aws_lb.rag_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rag_frontend_tg.arn
  }
}

# --------------------------
# Listener for Backend (Port 18000)
# -------------------------
resource "aws_lb_listener" "rag_backend_listener" {
  load_balancer_arn = aws_lb.rag_alb.arn
  port              = 18000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rag_backend_tg.arn
  }
}
