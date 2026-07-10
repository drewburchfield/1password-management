<div align="center">

<img src="https://ghrb.waren.build/banner?header=1password-management%20![1password]&subheader=1Password%20CLI%20for%20agents%20and%20dev%20workflows&bg=0a1628&secondaryBg=1e3a5f&color=e8f0fe&subheaderColor=7eb8da&headerFont=Inter&subheaderFont=Inter&support=false" alt="1password-management" width="100%">

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin from the [not-my-job](https://github.com/drewburchfield/not-my-job) marketplace.

![License](https://img.shields.io/badge/license-MIT-blue)
![Version](https://img.shields.io/badge/version-1.1.0-blue)

</div>

## What it does

Full `op` workflow skill for coding agents and developers:

- **Auth** — desktop integration, multi-account, service accounts for CI/agents
- **CRUD** — create/edit/list items with correct field types, quoting, categories, tags
- **Runtime secrets** — `op read`, `op run`, `op inject`, secret references (`op://Vault/Item/field`)
- **Agent hygiene** — prefer run/inject over printing secrets into chat

OpenClaw SecretRef setup lives in [openclaw-1password](https://github.com/drewburchfield/openclaw-1password).

## Install

```bash
claude plugins install 1password-management@not-my-job
```

## Structure

```text
skills/1password-management/
  SKILL.md                      # always-on contract
  references/item-create.md     # create/edit recipes
  references/secrets-runtime.md # run / inject / SA / CI
```

## License

MIT
