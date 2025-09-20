output "ecr_backend" {
  value = aws_ecr_repository.backend.repository_url
}

output "ecr_frontend" {
  value = aws_ecr_repository.frontend.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.rag_cluster.name
}

output "alb_dns_name" {
  value = aws_lb.rag_alb.dns_name
}