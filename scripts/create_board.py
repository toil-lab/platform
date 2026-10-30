"""Create the org's Projects board, set its Status columns, and link the repos.

Terraform's github provider can't manage Projects (v2), so this runs once
through the GitHub CLI. Safe to run again: it reuses a board with the same
title and resets the Status options.

Usage: python scripts/create_board.py [--owner toil-lab] [--title toil-lab]
Needs: gh with the project scope (gh auth refresh -s project).
"""
import argparse, json, subprocess, sys

REPOS = ["agents", "platform", "checks", "status"]

# A handoff shows as a card moving between the two agent columns.
COLUMNS = [
    ("Requested", "GRAY", "Filed, not picked up yet"),
    ("Dev working", "BLUE", "Developer agent owns the next step"),
    ("Ops working", "PURPLE", "DevOps agent owns the next step"),
    ("Needs approval", "YELLOW", "Waiting on a human review"),
    ("Done", "GREEN", "Merged or closed"),
]


def gh(*args, input=None):
    r = subprocess.run(["gh", *args], input=input, capture_output=True, text=True)
    if r.returncode != 0:
        sys.exit(f"gh {' '.join(args[:3])} failed: {r.stderr.strip()}")
    return r.stdout


def graphql(query, **variables):
    out = gh("api", "graphql", "--input", "-", input=json.dumps({"query": query, "variables": variables}))
    return json.loads(out)["data"]


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--owner", default="toil-lab")
    p.add_argument("--title", default="toil-lab")
    a = p.parse_args()

    projects = json.loads(gh("project", "list", "--owner", a.owner, "--format", "json"))["projects"]
    project = next((x for x in projects if x["title"] == a.title), None)
    if project is None:
        project = json.loads(gh("project", "create", "--owner", a.owner, "--title", a.title, "--format", "json"))
        print(f"created board #{project['number']}")
    else:
        print(f"using board #{project['number']}")

    fields = json.loads(gh("project", "field-list", str(project["number"]), "--owner", a.owner, "--format", "json"))
    status = next(f for f in fields["fields"] if f["name"] == "Status")
    graphql(
        """mutation($id: ID!, $opts: [ProjectV2SingleSelectFieldOptionInput!]) {
             updateProjectV2Field(input: {fieldId: $id, singleSelectOptions: $opts}) { clientMutationId }
           }""",
        id=status["id"],
        opts=[{"name": n, "color": c, "description": d} for n, c, d in COLUMNS],
    )
    print("status columns: " + ", ".join(n for n, _, _ in COLUMNS))

    for repo in REPOS:
        repo_id = json.loads(gh("api", f"repos/{a.owner}/{repo}"))["node_id"]
        graphql(
            """mutation($p: ID!, $r: ID!) {
                 linkProjectV2ToRepository(input: {projectId: $p, repositoryId: $r}) { clientMutationId }
               }""",
            p=project["id"],
            r=repo_id,
        )
        print(f"linked {repo}")
    print(project["url"])


if __name__ == "__main__":
    main()
