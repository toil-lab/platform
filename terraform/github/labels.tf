locals {
  # type: what the work is. agent: who picks it up. The rest feed the metrics
  # described in docs/design.md under Measurement.
  labels = {
    "type:feature"          = { color = "1d76db", description = "App behavior change, picked up by the developer agent" }
    "type:bug"              = { color = "d73a4a", description = "Something is broken" }
    "type:platform-request" = { color = "5319e7", description = "A service needs something from the platform" }
    "type:incident"         = { color = "b60205", description = "Opened by Alertmanager or a human during an incident" }
    "type:upgrade"          = { color = "0e8a16", description = "Dependency or platform component upgrade" }
    "type:cve"              = { color = "e99695", description = "Vulnerability to triage" }
    "agent:dev"             = { color = "c5def5", description = "Developer agent owns the next step" }
    "agent:ops"             = { color = "d4c5f9", description = "DevOps agent owns the next step" }
    "spec-bounce"           = { color = "fbca04", description = "DevOps review sent a service.yaml change back" }
    "root-cause:code"       = { color = "f9d0c4", description = "Incident or bug traced to app code" }
    "root-cause:platform"   = { color = "fef2c0", description = "Incident or bug traced to the platform" }
    "misrouted"             = { color = "ededed", description = "First routing of this issue went to the wrong agent" }
  }
}

# Authoritative: GitHub's default labels are removed from these repos.
resource "github_issue_labels" "repo" {
  for_each = { for name, r in local.repos : name => r if name != ".github" }

  repository = github_repository.repo[each.key].name

  dynamic "label" {
    for_each = local.labels

    content {
      name        = label.key
      color       = label.value.color
      description = label.value.description
    }
  }
}
