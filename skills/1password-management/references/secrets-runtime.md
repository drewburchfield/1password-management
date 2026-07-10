# Secrets runtime: read, run, inject

Load when integrating apps, CI, or agents with 1Password without baking secrets into files or chat.

## Secret reference syntax

```
op://<vault>/<item>/<field>
```

Vault, item, and field can be names or IDs. Spaces in names are fine inside quotes.

Optional query params (examples):

```bash
op read "op://Vault/Item/one-time password?attribute=otp"
```

## `op read`

Single secret to stdout (use sparingly in agent context; prefer run/inject):

```bash
op read "op://Dev Environments/myapp - API/API_KEY"
op read "op://Dev Environments/myapp - API/API_KEY" --no-newline
```

## `op run`

Scan env (and optionally files) for `op://` references, resolve them, run a child process with real values only in that process environment.

```bash
# Inline
export DATABASE_URL="op://Dev Environments/myapp - DB/connection"
op run -- ./server

# Env file containing op:// refs (safe to commit)
# .env.op:
#   API_KEY=op://Dev Environments/myapp - API/API_KEY
op run --env-file=.env.op -- docker compose up

# Mask secrets in child stdout by default; --no-masking only when debugging carefully
op run -- printenv API_KEY
```

**Agent default:** `op run --` for any command that needs secrets. Do not `export $(op read ...)` into the agent shell session when avoidable.

## `op inject`

Resolve `{{ op://... }}` templates into a config file:

```bash
# config.tpl
# api_token: {{ op://Dev Environments/myapp - API/API_KEY }}

op inject -i config.tpl -o /tmp/config.yaml
# use the file, then delete resolved output
rm -P /tmp/config.yaml 2>/dev/null || rm /tmp/config.yaml

# stdin
echo 'token: {{ op://V/Item/field }}' | op inject
```

Never commit resolved files. Commit only templates with `op://` or `{{ op:// }}` placeholders.

## Service accounts (automation)

```bash
export OP_SERVICE_ACCOUNT_TOKEN="ops_..."
op whoami
```

- Create at 1Password → Developer → Service Accounts
- Scope to specific vaults only
- Store token in host secret store or chmod 600 env file outside git
- Use with `op read` / `op run` / `op inject` (no desktop app required)

Headless macOS (reduce TCC prompts when SA is used):

```bash
export OP_BIOMETRIC_UNLOCK_ENABLED=false
export OP_NO_AUTO_SIGNIN=true
export OP_LOAD_DESKTOP_APP_SETTINGS=false
```

## Multi-account

```bash
op account list
op item list --account my.1password.com --vault "Work"
# or
export OP_ACCOUNT=team-shorthand
```

## Plugins (shell)

`op plugin` integrates third-party CLIs with 1Password auth. Use when the user wants AWS/gh/etc. aliases backed by 1Password; see `op plugin --help` and 1Password shell plugins docs.

## Agent do / don't

| Do | Don't |
|----|--------|
| `op run -- cmd` | Dump `op item get --reveal` into chat |
| Commit `.env` with only `op://` refs | Commit real tokens |
| SA for CI/agents | Broad personal account tokens in CI |
| Delete injected output files | Leave resolved secrets on disk |
