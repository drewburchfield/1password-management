# Authentication

## Desktop app integration (interactive)

1. 1Password app → Settings → Developer → **Integrate with 1Password CLI**
2. Keep app unlocked when using biometric prompts
3. `op signin` if needed; approve in app
4. `op whoami` to confirm

## Multi-account

```bash
op account list
op item list --account <shorthand|signin-address|account-id|user-id> --vault "Vault"
export OP_ACCOUNT=my.1password.com   # default for subsequent commands
```

Global flag `--account` works on all commands.

## Service account (agents, CI, OpenClaw, headless)

```bash
export OP_SERVICE_ACCOUNT_TOKEN="ops_..."
op whoami   # Type: SERVICE_ACCOUNT
```

- Create: 1Password → Developer → Service Accounts
- Grant **least-privilege** vault access only
- Store token outside git (`chmod 600` env file, CI secret, OpenClaw `.env`)
- Supports `op read`, `op run`, `op inject`, item list/get for allowed vaults

Headless macOS (when not using interactive desktop unlock):

```bash
export OP_BIOMETRIC_UNLOCK_ENABLED=false
export OP_NO_AUTO_SIGNIN=true
export OP_LOAD_DESKTOP_APP_SETTINGS=false
```

## Connect server

```bash
export OP_CONNECT_HOST="http://localhost:8080"
export OP_CONNECT_TOKEN="..."
```

## Session token (legacy / no app integration)

`op signin` can emit a session; pass `--session` or env when app integration is off. Prefer app integration or service accounts.

## Sign out

```bash
op signout
op signout --all
```

## Diagnose

| Symptom | Check |
|---------|--------|
| `account is not signed in` | `op whoami`; signin or SA token |
| Wrong vault / account | `op account list`; `--account` |
| Permission denied on item | SA vault grants; vault name spelling |
| Biometric / TCC loop on headless | SA + TCC env vars above |
