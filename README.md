# Arkwright Factory

Arkwright is a team of coding agents that takes a piece of work from a rough request
to a reviewed pull request. You describe a bug or a feature to Arkwright. It
investigates, writes a plan for you to approve, has the change made and
reviewed, and hands you a PR to merge.

It works with [Claude Code](https://code.claude.com),
[Codex CLI](https://github.com/openai/codex), and
[GitHub Copilot CLI](https://github.com/github/copilot-cli). The agents are
plain prompt files, so there is nothing to build or run apart from the tool you
already use.

## How it works

You only ever talk to Arkwright. Behind it are four specialist agents:

| Agent | Job |
| --- | --- |
| `arkwright` | Talks to you and hands work to the other agents. Never edits code. |
| `triage` | Researches the request, reproduces bugs, and finds or creates the issue. |
| `plan` | Interviews you, then writes the plan and commits it to the branch. |
| `implement` | Makes the change, proves it works, and opens the PR. |
| `review` | Reviews the PR adversarially and reports back to Arkwright. Never edits code. |

```mermaid
flowchart LR
    req([Your request]) --> triage

    subgraph arkwright [Arkwright coordinates]
        direction LR
        triage[Triage] --> plan[Plan]
        plan --> approve{You approve?}
        approve -->|yes| implement[Implement]
        approve -->|changes| plan
        implement --> review[Review]
        review -->|fixes needed| implement
    end

    review -->|accepted| merge([You merge the PR])

    classDef user fill:#fde68a,stroke:#b45309,color:#451a03
    classDef agent fill:#bfdbfe,stroke:#1d4ed8,color:#172554
    classDef gate fill:#fecaca,stroke:#b91c1c,color:#450a0a
    classDef done fill:#bbf7d0,stroke:#15803d,color:#052e16
    class req user
    class triage,plan,implement,review agent
    class approve gate
    class merge done
```

Arkwright skips stages that aren't needed: a trivial fix doesn't need a plan, and a
link to an open issue doesn't need triage.

Arkwright stops and waits for you when:

- a plan is ready, because no code is written until you approve it
- an agent has a question for you
- review raises a decision that is yours to make
- the PR is reviewed and ready for you to merge

## Install

Clone this repository first:

```bash
git clone https://github.com/matt-major/arkwright-factory.git
```

```bash
cd arkwright-factory
```

To run the interactive installer, run:

```bash
./install.sh
```

To skip the questions, you can install it directly to your tool of choice:

```bash
./install.sh claude
```

```bash
./install.sh codex
```

```bash
./install.sh copilot
```

Or install it for every supported tool on your PATH at once:

```bash
./install.sh all
```

By default the installer installs the agents into your global tool directory. If you'd like to install them only in a single project instead, run the script inside your project directory and pass the argument `--project`:

```bash
cd your-project
```

```bash
../arkwright-factory/install.sh --project claude
```

There are a few extra flags to customise the installation if you need them:

| Option | Effect |
| --- | --- |
| `-p`, `--project` | Install into the current project instead of your home directory. |
| `-y`, `--yes` | Don't ask. Defaults to all tools. |
| `--link` | Symlink the files instead of copying them. |

The installer will install the agents at the following locations, depending on your choices:

| Tool | Project | Global |
| --- | --- | --- |
| Claude Code | `.claude/agents/` | `~/.claude/agents/` |
| Codex CLI | `.codex/agents/` | `~/.codex/agents/` |
| Copilot CLI | `.github/agents/` | `~/.copilot/agents/` |

Codex reads profiles only from its home directory, so Arkwright's Codex profile
always goes to `~/.codex`, even for a project install. Codex also loads project
agents only in a trusted project.

To update, pull this repository and run the script again.

## Usage

Start Arkwright from inside the repository you want to work on, then tell it what
you want done, for example "the login page 500s when the email has a plus
sign", or paste a link to an issue.

Claude Code:

```bash
claude --agent arkwright
```

Codex CLI:

```bash
codex -p arkwright
```

GitHub Copilot CLI:

```bash
copilot --agent arkwright
```

Your forge and issue tracker need to be reachable from the tool, for example
through the `gh` CLI or an MCP server, so the agents can open PRs and read and
update issues.

## Repository Layout

```
claude/agents/                  Claude Code  (*.md)
codex/agents/                   Codex CLI    (*.toml)
codex/arkwright.config.toml     Arkwright's Codex profile
copilot/agents/                 Copilot CLI  (*.agent.md)
install.sh
```

To change an agent or the installer, see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
