locals {
  # App ID of GitHub Actions. Tying required checks to it stops anything else
  # from satisfying them with a commit status of the same name.
  github_actions_app_id = 15368

  # Every PR in every repo needs these, on top of the repo's own checks.
  # pr-metrics fails until the approver writes "Human minutes:" in the PR.
  common_checks = ["pr-metrics / human-minutes"]
}

resource "github_repository_ruleset" "main" {
  for_each = local.repos

  name        = "main"
  repository  = github_repository.repo[each.key].name
  target      = "branch"
  enforcement = var.ruleset_enforcement

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  # Org owners may merge their own PRs without a second reviewer (there is only
  # one human), but only through a PR. Nobody pushes to main directly.
  bypass_actors {
    actor_id    = 1
    actor_type  = "OrganizationAdmin"
    bypass_mode = "pull_request"
  }

  rules {
    deletion         = true
    non_fast_forward = true

    # Code owners are teams, and only humans are in teams, so an approval from
    # either agent's App never satisfies this rule.
    pull_request {
      required_approving_review_count   = 1
      require_code_owner_review         = true
      dismiss_stale_reviews_on_push     = true
      require_last_push_approval        = true
      required_review_thread_resolution = true
      allowed_merge_methods             = ["squash"]
    }

    required_status_checks {
      strict_required_status_checks_policy = false

      dynamic "required_check" {
        for_each = concat(local.common_checks, each.value.checks)

        content {
          context        = required_check.value
          integration_id = local.github_actions_app_id
        }
      }
    }
  }
}
