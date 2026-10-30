locals {
  # kind matches toil.json in each repo. checks lists the status checks a PR must
  # pass, besides the common_checks in rulesets.tf.
  repos = {
    agents = {
      team        = "platform"
      kind        = "agents"
      description = "Claude Code plugins for a developer agent and a DevOps agent, plus the service.yaml contract"
      checks      = ["test", "test-py38"]
    }
    platform = {
      team        = "platform"
      kind        = "platform"
      description = "Cluster bootstrap, tenancy, GitOps, policies, monitoring, and the Terraform for this org"
      checks      = ["terraform"]
    }
    checks = {
      team        = "checks"
      kind        = "app"
      description = "statuspage: check-scheduler and probe-worker"
      checks      = ["service-spec / validate"]
    }
    status = {
      team        = "status"
      kind        = "app"
      description = "statuspage: status-api, result-ingester, status-web, and rollup"
      checks      = ["service-spec / validate"]
    }
    ".github" = {
      team        = "platform"
      kind        = "platform"
      description = "Default issue and pull request templates for every toil-lab repo"
      checks      = []
    }
  }

  app_repos = { for name, r in local.repos : name => r if r.kind == "app" }
}

resource "github_repository" "repo" {
  for_each = local.repos

  name        = each.key
  description = each.value.description
  visibility  = "public"
  topics      = ["kubernetes", "devops", "claude-code", "platform-engineering"]

  has_issues      = each.key != ".github"
  has_projects    = false
  has_wiki        = false
  has_discussions = false

  # Squash only, so each PR is one commit on main. The commit body keeps the
  # Agent: trailers from the branch's commits.
  allow_merge_commit          = false
  allow_rebase_merge          = false
  allow_squash_merge          = true
  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "COMMIT_MESSAGES"
  allow_update_branch         = true
  delete_branch_on_merge      = true

  # Public history can't be taken back; archive instead of deleting.
  archive_on_destroy = true

  security_and_analysis {
    secret_scanning {
      status = "enabled"
    }
    secret_scanning_push_protection {
      status = "enabled"
    }
  }
}
