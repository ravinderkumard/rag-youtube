variable "existing_vpc_id" {
  type        = string
  default     = ""
  description = "Existing VPC ID, leave empty to create new"
}

variable "existing_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Existing subnet IDs, leave empty to create new"
}

variable "existing_sg_id" {
  type        = string
  default     = ""
  description = "Existing security group ID, leave empty to create new"
}

variable "existing_ecs_role_arn" {
  type        = string
  default     = ""
  description = "Existing ECS Task Execution Role ARN, leave empty to create new"
}

variable "existing_alb_sg_id" {
  type        = string
  description = "Existing ALB security group ID (optional)"
  default     = ""
}