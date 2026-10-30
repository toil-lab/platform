# github stack

Everything inside the `toil-lab` organization except the organization itself
(GitHub has no API to create one) and the Projects board (the provider can't
manage Projects; `scripts/create_board.py` does it).

| File | Manages |
|---|---|
| `repos.tf` | The five repos, their merge settings, and secret scanning |
| `teams.tf` | `platform`, `checks`, and `status` teams, their members, and repo access |
| `rulesets.tf` | One ruleset per repo on the default branch: PR only, code owner approval, required checks (`pr-metrics / human-minutes` on every repo plus its own) |
| `labels.tf` | The same label set in every repo with issues |
| `actions.tf` | Which actions may run, and read-only workflow tokens that can't approve PRs |

The agents act through two GitHub Apps, `toil-dev-bot` (App ID 5535069) and
`toil-ops-bot` (App ID 5535114). They were created by hand in the org
settings, because Terraform can't create a GitHub App, and are installed on all
repos. `toil-dev-bot` has no Workflows permission, so GitHub refuses any push
from it that changes `.github/workflows/`.

## Running it

State is local and gitignored until phase 5 moves it to a GCS bucket.

```sh
terraform init
terraform plan
terraform apply
```

The provider uses `GITHUB_TOKEN` if set, otherwise `gh auth token`. The token
needs the `repo`, `admin:org`, and `workflow` scopes.

## Bootstrap

A new repo has no default branch until its first push, and the rulesets block
direct pushes. The first apply runs with the rulesets off, the first commit is
pushed to each repo, and a second apply turns them on:

```sh
terraform apply -var ruleset_enforcement=disabled
# push the first commit to each repo
terraform apply
```
