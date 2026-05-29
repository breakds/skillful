---
name: fj
description: >
  Use the `fj` Forgejo CLI to interact with Forgejo/Gitea forges from the
  terminal: repos, issues, pull requests, releases, actions, wikis, users,
  and orgs. Use when the user wants to open/list/merge PRs, file or search
  issues, clone/create repos, cut releases, or otherwise operate on a Forgejo
  instance without the web UI.
---

# fj — Forgejo CLI

`fj` is a command-line client for Forgejo/Gitea forges. It mirrors the
forge's web features (repos, issues, PRs, releases, CI) so you can stay in
the terminal. The default instance is already configured in the environment,
so commands target it automatically — no host flag needed. Inside a git
checkout, `fj` operates on that repo by default.

## Repo selection flags

- `-R, --remote <NAME>` — pick the repo from a local git remote name.
- `-r, --repo <OWNER/NAME>` — name the repo explicitly when not inside its checkout.
- `--style fancy|minimal` (global) — colored/decorated vs plain output. Plain
  is forced automatically when piping, so output is safe to `grep`/parse.

## Authentication

```sh
fj auth list      # which instances you're logged into
fj whoami         # who am I
fj auth login     # browser-based login
fj auth logout    # remove stored login
```

## Repositories

```sh
fj repo view OWNER/NAME            # repo info
fj repo readme OWNER/NAME          # print README
fj repo clone OWNER/NAME [PATH]    # clone (-S for SSH)
fj repo create NAME                # create a repo (-d desc, -P private,
                                    #   -p push current branch, -S ssh)
fj repo fork OWNER/NAME            # fork to your account
fj repo star / unstar OWNER/NAME
fj repo delete OWNER/NAME
fj repo browse OWNER/NAME          # open in browser
```

Create a repo and push the current branch in one shot:

```sh
fj repo create my-project -d "experiment" -P -p
```

## Issues

```sh
fj issue create [TITLE] [--body TEXT] [-r OWNER/NAME] [--web]
fj issue search [QUERY] [-s open|closed] [-l LABELS] [-c CREATOR] [-a ASSIGNEE]
fj issue view <ID>
fj issue comment <ID> [--body TEXT]
fj issue edit <ID>
fj issue close <ID>
fj issue browse <ID>
```

Omitting `--body` opens your `$EDITOR` for the text. Example:

```sh
fj issue create "Crash on empty input" --body "Steps: ..."
fj issue search "panic" -s open -a breakds
```

## Pull requests

```sh
fj pr create [TITLE] [--base BRANCH] [--head BRANCH] [--body TEXT] [-w] [-a]
fj pr search [QUERY] [-s open|closed] [-l LABELS] [-c CREATOR] [-a ASSIGNEE]
fj pr view <PR>
fj pr status <PR>                 # mergeability + CI status
fj pr checkout <ID> [--branch-name NAME] [-S]
fj pr comment <PR> [--body TEXT]
fj pr edit <PR>
fj pr merge <PR> [-M merge|rebase|rebase-merge|squash|manual] [-d] [-t TITLE] [-m MSG]
fj pr close <PR>                  # close without merging
fj pr browse <PR>
```

Notes:
- Prefix a PR title with `WIP: ` to create it as a draft.
- In `pr checkout`, prefix the id with `^` to grab a PR from the *parent* repo.
- `pr merge -d` deletes the source branch after merging.

Typical flow from a feature branch:

```sh
fj pr create "Add retry logic" --base main --head my-feature --body "..."
fj pr status 42
fj pr merge 42 -M squash -d
```

## Releases

```sh
fj release list [-r OWNER/NAME]
fj release view <NAME>
fj release create <NAME> [-T [TAG]] [-t EXISTING_TAG] [-B BRANCH] \
                         [-b [BODY]] [-a FILE[:ASSET_NAME]] [-d] [-p]
fj release edit <NAME>
fj release delete <NAME>
fj release asset ...              # manage attached files
fj release browse <NAME>
```

- `-T/--create-tag` makes a new tag (defaults to the release name);
  `-t/--tag` reuses an existing tag.
- `-d` draft, `-p` prerelease. `-a path:name` attaches a file under a custom name.

```sh
fj release create v1.2.0 -T -b "Highlights..." -a ./dist/app.tar.gz:app-linux.tar.gz
```

## Actions (CI)

```sh
fj actions tasks                  # list CI tasks/runs
fj actions variables ...          # list/manage variables
fj actions secrets ...
fj actions dispatch <WORKFLOW>    # trigger a workflow_dispatch
```

## Wiki

```sh
fj wiki contents                  # list pages
fj wiki view <PAGE>
fj wiki clone
fj wiki browse
```

## Users & orgs

```sh
fj user search <NAME>
fj user view <NAME>
fj user repos <NAME>              # also: orgs, activity, followers, following
fj user follow / unfollow / block / unblock <NAME>
fj user edit                      # edit your own settings

fj org list
fj org view <NAME>
fj org create <NAME>
fj org members <NAME>
fj org team / label / repo ...    # org sub-resources
```

## Tips

- Add `--web` / `-w` (where supported) to open the action in a browser instead.
- Run `fj <command> --help` (or `fj <command> <subcommand> --help`) for the
  authoritative, version-specific flag list.
