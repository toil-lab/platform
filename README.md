# platform

The toil-lab platform: everything the app teams deploy onto. The DevOps agent
(`ops-agent` in [toil-lab/agents](https://github.com/toil-lab/agents)) owns
this repo, and a human approves every merge.

| Path | Contents |
|---|---|
| `terraform/github/` | The GitHub organization: repos, teams, rulesets, labels, Actions policy |
| `scripts/create_board.py` | Creates the org's Projects board and its Status columns |
| `.github/workflows/service-spec.yml` | Reusable check that validates `toil.json` and every `service.yaml` in an app repo |

Cluster bootstrap, tenancy, Argo CD, policies, and monitoring arrive in later
phases. The full plan is in the design doc.
