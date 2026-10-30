output "repos" {
  description = "Clone URLs by repo name."
  value       = { for name, r in github_repository.repo : name => r.http_clone_url }
}

output "teams" {
  description = "Team slugs, for CODEOWNERS."
  value       = { for name, t in github_team.team : name => "@${var.owner}/${t.slug}" }
}
