# Actions and reusable workflows from toil-lab itself are always allowed.
resource "github_actions_organization_permissions" "org" {
  enabled_repositories = "all"
  allowed_actions      = "selected"

  allowed_actions_config {
    github_owned_allowed = true
    verified_allowed     = false
    patterns_allowed     = ["hashicorp/setup-terraform@*"]
  }
}

# Workflow tokens are read-only unless a workflow asks for more, and can never
# approve a PR.
resource "github_actions_organization_workflow_permissions" "org" {
  organization_slug                = var.owner
  default_workflow_permissions     = "read"
  can_approve_pull_request_reviews = false
}
