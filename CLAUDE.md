# CLAUDE.md

Project guidance for Claude Code. The authoritative instructions for working in this
repository live in **[AGENTS.md](AGENTS.md)** — read it first.

@AGENTS.md

## Notes for Claude
- This is a **public** repository. Never commit internal hostnames, CI configuration IDs,
  server addresses, tokens, or credentials.
- Images are built by softvision's internal CI; Docker Hub is registry-only. Do not
  re-introduce Docker Hub Automated Build artifacts (`hooks/`, `LATEST_VERSION_*`, tag/regex rules).
- The detailed internal build/CI setup is intentionally **not** documented in this repo.
