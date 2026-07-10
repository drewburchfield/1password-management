<div align="center">

<img src="https://ghrb.waren.build/banner?header=1password-management%20![1password]&subheader=1Password%20CLI%20syntax%20done%20right&bg=0a1628&secondaryBg=1e3a5f&color=e8f0fe&subheaderColor=7eb8da&headerFont=Inter&subheaderFont=Inter&support=false" alt="1password-management" width="100%">

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin from the [not-my-job](https://github.com/drewburchfield/not-my-job) marketplace.

![License](https://img.shields.io/badge/license-MIT-blue)

</div>

## What it does

Reference for correct `op item create` / edit syntax: field types, categories, quoting rules, tagging, and notes templates for developer credentials.

**Scope (current):** strongest on **item create and field-type hygiene**. Day-to-day agent patterns (`op run`, `op inject`, service accounts, multi-account auth) are only lightly covered; treat this as a create/edit cheat sheet, not a full agent secrets runtime guide.

For OpenClaw SecretRef setup, use [openclaw-1password](https://github.com/drewburchfield/openclaw-1password) instead.

## Install

```
claude plugins install 1password-management@not-my-job
```

## License

MIT
