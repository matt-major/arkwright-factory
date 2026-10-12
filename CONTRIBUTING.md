# Contributing

Thanks for helping improve Arkwright. The agents are plain prompt files, so most
changes are edits to prose. The rules below keep the three tools in step.

## Keep the three copies in sync

Each agent exists once per tool, and the copies are maintained by hand:

| Agent | Claude Code | Codex CLI | Copilot CLI |
| --- | --- | --- | --- |
| `arkwright` | `claude/agents/arkwright.md` | `codex/arkwright.config.toml` | `copilot/agents/arkwright.agent.md` |
| `triage` | `claude/agents/triage.md` | `codex/agents/triage.toml` | `copilot/agents/triage.agent.md` |
| `plan` | `claude/agents/plan.md` | `codex/agents/plan.toml` | `copilot/agents/plan.agent.md` |
| `implement` | `claude/agents/implement.md` | `codex/agents/implement.toml` | `copilot/agents/implement.agent.md` |
| `review` | `claude/agents/review.md` | `codex/agents/review.toml` | `copilot/agents/review.agent.md` |

When you change how an agent behaves, make the same change in all three files.
The prompt text should match. Only the wrapping around it differs:

- **Claude Code**: YAML frontmatter (`name`, `description`, `model`, `effort`,
  tool restrictions), then the prompt as Markdown.
- **Codex CLI**: TOML, with the prompt in `developer_instructions = """ ... """`.
  This is a TOML basic string, so a backslash in the prompt must be written as
  `\\`. Arkwright itself is a Codex profile, not an agent, so it lives in
  `codex/arkwright.config.toml`.
- **Copilot CLI**: YAML frontmatter (`name`, `description`, and
  `user-invocable` for subagents or `disable-model-invocation` for Arkwright),
  then the prompt as Markdown.

Settings such as models, effort and tool restrictions are tool-specific. Change
them only for the tool you mean to.

## Test your change

Install from your clone with `--link`, so the tools read your working copy as
you edit:

```bash
./install.sh --link all
```

Then start Arkwright in a scratch repository with each tool you changed, and run
a request that exercises the behaviour. See [Usage](README.md#usage).

### Testing the installer

If you change `install.sh`, check the syntax:

```bash
bash -n install.sh
```

Then run it with a temporary home directory, so it doesn't touch your real
install:

```bash
HOME="$(mktemp -d)" CODEX_HOME="" ./install.sh -y
```

Also try `--project` from inside a scratch repository, and check that the
README's install instructions still match the script.

## Pull requests

- Keep each PR to one change in behaviour, applied to all three tools.
- Describe what the agents now do differently, and how you tested it.
- If you change the installer's flags or defaults, update the README.
