<div align="center">

<img src="https://ghrb.waren.build/banner?header=1password-management%20![1password]&subheader=1Password%20CLI%20for%20agents%20and%20dev%20workflows&bg=0a1628&secondaryBg=1e3a5f&color=e8f0fe&subheaderColor=7eb8da&headerFont=Inter&subheaderFont=Inter&support=false" alt="1password-management" width="100%">

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin from the [not-my-job](https://github.com/drewburchfield/not-my-job) marketplace.

![License](https://img.shields.io/badge/license-MIT-blue)
![Version](https://img.shields.io/badge/version-1.3.0-blue)

</div>

## What it does

1Password CLI (`op`) skill for coding agents and developers:

- Auth: desktop integration, multi-account, service accounts, Connect
- Items: create, edit, list, get with correct field types and quoting
- Runtime: secret references, `op read`, `op run`, `op inject`
- Environments (beta): locally mounted `.env` files, MCP server config, agent hooks
- SSH & Git: the 1Password SSH agent, key management, commit signing
- Vaults, documents, shell plugins
- Agent hygiene for safe secret handling

Checked against 1Password's own documentation, and it points agents at
[`llms.txt`](https://www.1password.dev/llms.txt) rather than trusting recall.
1Password's official Environments-via-MCP workflow is vendored under
`references/upstream/` and refreshed with `scripts/upstream-sync.sh`.

OpenClaw SecretRef / gateway: [openclaw-1password](https://github.com/drewburchfield/openclaw-1password).

## Install

```bash
claude plugins install 1password-management@not-my-job
```

## Layout

```text
skills/1password-management/
  SKILL.md
  references/
    auth.md
    agent-hygiene.md
    item-create.md
    secrets-runtime.md
    environments.md
    ssh-git.md
    upstream/              # vendored from 1Password, generated
      1password-environments.md
      1password-environments-reference.md
      UPSTREAM.md
      upstream.manifest
scripts/
  upstream-sync.sh         # refresh the vendored payload; --check reports drift
```

## Refreshing vendored upstream content

```bash
scripts/upstream-sync.sh --check   # drift report, changes nothing
scripts/upstream-sync.sh           # pull it in, then read the git diff
```

`references/upstream/` is a mirror of 1Password's official
[Cursor plugin](https://github.com/1Password/cursor-plugin) skill (MIT).
Never hand-edit it; our own guidance lives in `SKILL.md` and the sibling
reference files, so upstream refreshes can never conflict.

## License

MIT
