<div align="center">

<img src="https://ghrb.waren.build/banner?header=1password-management%20![1password]&subheader=1Password%20CLI%20for%20agents%20and%20dev%20workflows&bg=0a1628&secondaryBg=1e3a5f&color=e8f0fe&subheaderColor=7eb8da&headerFont=Inter&subheaderFont=Inter&support=false" alt="1password-management" width="100%">

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin from the [not-my-job](https://github.com/drewburchfield/not-my-job) marketplace.

![License](https://img.shields.io/badge/license-MIT-blue)
![Version](https://img.shields.io/badge/version-1.2.1-blue)

</div>

## What it does

1Password CLI (`op`) skill for coding agents and developers:

- Auth: desktop integration, multi-account, service accounts, Connect
- Items: create, edit, list, get with correct field types and quoting
- Runtime: secret references, `op read`, `op run`, `op inject`
- Vaults, documents, shell plugins
- Agent hygiene for safe secret handling

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
```

## License

MIT
