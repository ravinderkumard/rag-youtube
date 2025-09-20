resource "aws_ecr_repository" "backend" {
  name = "rag-backend"
}

resource "aws_ecr_repository" "frontend" {
  name = "rag-frontend"
}
