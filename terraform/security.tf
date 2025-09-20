# -------------------------
# Security Group for ECS Tasks (Backend + Frontend)
# -------------------------
resource "aws_security_group" "rag_sg" {
  name        = "rag-sg"
  vpc_id      = aws_vpc.rag_vpc.id
  description = "Allow traffic only from ALB for backend and frontend services"

  # Allow inbound traffic from ALB SG for Backend
  ingress {
    from_port       = 18000
    to_port         = 18000
    protocol        = "tcp"
    security_groups = [local.alb_sg_id] # Reuse local from alb.tf
  }

  # Allow inbound traffic from ALB SG for Frontend
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [local.alb_sg_id] # Reuse local from alb.tf
  }

  # Allow all outbound traffic (to internet / ALB / AWS services)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rag-sg"
  }
}
