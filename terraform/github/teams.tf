locals {
  # Team names match the team field in toil.json and service.yaml.
  teams = {
    platform = "Owns the platform, agents, and .github repos, and CI and CODEOWNERS in every repo"
    checks   = "Owns the checks repo: check-scheduler and probe-worker"
    status   = "Owns the status repo: status-api, result-ingester, status-web, and rollup"
  }
}

resource "github_team" "team" {
  for_each = local.teams

  name        = each.key
  description = each.value
  privacy     = "closed"
}

# The agents are GitHub Apps and can't join teams, so a code owner review
# always comes from a human.
resource "github_team_members" "team" {
  for_each = github_team.team

  team_slug = each.value.slug

  members {
    username = var.approver
    role     = "maintainer"
  }
}

resource "github_team_repository" "owner" {
  for_each = local.repos

  team_id    = github_team.team[each.value.team].id
  repository = github_repository.repo[each.key].name
  permission = "maintain"
}

# CODEOWNERS in app repos names the platform team for .github/, CODEOWNERS,
# and toil.json, and code owners need write access.
resource "github_team_repository" "platform_on_apps" {
  for_each = local.app_repos

  team_id    = github_team.team["platform"].id
  repository = github_repository.repo[each.key].name
  permission = "push"
}
