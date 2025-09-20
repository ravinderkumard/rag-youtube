# Generate random suffix for new role
resource "random_string" "suffix" {
  length  = 6
  special = false
}

# Create ECS Task Execution Role if no existing role is provided
resource "aws_iam_role" "ecs_task_execution_role" {
  count = var.existing_ecs_role_arn == "" ? 1 : 0
  name  = "ecsTaskExecutionRole-${random_string.suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach ECS execution policy to the newly created role
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  count      = var.existing_ecs_role_arn == "" ? 1 : 0
  role       = aws_iam_role.ecs_task_execution_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Use existing role ARN if provided
locals {
  ecs_task_execution_role_arn = var.existing_ecs_role_arn != "" ? var.existing_ecs_role_arn : aws_iam_role.ecs_task_execution_role[0].arn
}
