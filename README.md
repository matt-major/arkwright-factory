# Hugo Factory

Hugo is a set of coding agents that takes a piece of work from a rough request
to a reviewed pull request. The agents are being rewritten from scratch; the
files below are stubs with only their metadata.

| Agent | Job |
| --- | --- |
| `hugo` | Talks to the user and hands work to the other agents. |
| `triage` | Investigates the request and opens or updates the issue. |
| `plan` | Writes the plan. |
| `implement` | Makes the change and opens the PR. |
| `review` | Reviews the PR. |

```
claude/agents/     Claude Code  (*.md)
codex/agents/      Codex CLI    (*.toml)
codex/hugo.config.toml          Hugo's Codex profile
copilot/agents/    Copilot CLI  (*.agent.md)
```

## License

[MIT](LICENSE)
