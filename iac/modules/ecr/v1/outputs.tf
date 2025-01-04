output "repository_name" {
  description = "Name of the repository"
  value       = aws_ecr_repository.ecr_repo.name
}

output "public_repository_url" {
  description = "The URL of the repository"
  value       = aws_ecr_repository.ecr_repo.repository_url
}