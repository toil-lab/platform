# Authenticates with GITHUB_TOKEN if set, otherwise with the GitHub CLI's token.
# The token needs the repo, admin:org, and workflow scopes.
provider "github" {
  owner = var.owner
}
