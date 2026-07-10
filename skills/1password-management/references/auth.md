# Authentication

## Desktop app (interactive)

1. App → Settings → Developer → **Integrate with 1Password CLI**
2. Keep the app unlocked for biometric prompts
3. `op signin` if needed; approve in app
4. `op whoami`

Docs: [app integration](https://www.1password.dev/cli/app-integration)

## Multi-account

```bash
op account list
op item list --account <shorthand|signin-address|account-id|user-id> --vault "Vault"
export OP_ACCOUNT=my.1password.com
```

`--account` works on all commands. `OP_ACCOUNT` sets the default.

## Service account (agents, CI, headless)

```bash
export OP_SERVICE_ACCOUNT_TOKEN="ops_..."
op whoami   # Type: SERVICE_ACCOUNT
```

- Create: Developer → Service Accounts; least-privilege vault access
- Store token outside git (`chmod 600` env file, CI secret)
- Use for `op read`, `op run`, `op inject`, and allowed list/get

Docs: [service accounts + CLI](https://www.1password.dev/service-accounts/use-with-1password-cli) · [env vars](https://www.1password.dev/cli/environment-variables)

### Headless block (set wherever `op` runs)

Without a TTY (LaunchAgent, MCP, CI, env-cleared runners), `op` may still touch the desktop app and trip biometric prompts or macOS TCC ("access data from other apps"). With a service account, always export:

```bash
export OP_SERVICE_ACCOUNT_TOKEN="ops_..."
export OP_BIOMETRIC_UNLOCK_ENABLED=false
export OP_NO_AUTO_SIGNIN=true
export OP_LOAD_DESKTOP_APP_SETTINGS=false
```

| Var | Value | Does | Provenance |
|-----|-------|------|------------|
| `OP_SERVICE_ACCOUNT_TOKEN` | `ops_...` | SA auth; no interactive unlock | Official env-vars list |
| `OP_BIOMETRIC_UNLOCK_ENABLED` | `false` | Turns app/biometric integration off | Official env-vars + [app integration](https://www.1password.dev/cli/app-integration) |
| `OP_LOAD_DESKTOP_APP_SETTINGS` | `false` | Skips desktop settings / Group Containers (main TCC fix) | In `op` binary; [1Password staff](https://www.1password.community/discussions/developers/op-cli-with-biometric-unlock-using-polkit-not-working/85275) (undocumented control; `true` forces settings load for debug) |
| `OP_NO_AUTO_SIGNIN` | `true` | Blocks interactive sign-in / account-add prompts | In `op` binary; not on public env-vars page |

**Rules:**

1. Carry the full block into every sanitized context: LaunchAgent `EnvironmentVariables`, SecretRef `passEnv`, Docker env, `bash -c`. Shell profile alone is not enough.
2. Prefer only vars that exist in `op` (or official docs). Do not invent names.
3. Optional: `OP_CACHE=false` in tight agent runners (official).

## Connect server

```bash
export OP_CONNECT_HOST="http://localhost:8080"
export OP_CONNECT_TOKEN="..."
```

Official: `OP_CONNECT_HOST` + `OP_CONNECT_TOKEN` on the [env-vars](https://www.1password.dev/cli/environment-variables) page.

## Session token (legacy)

`op signin` can emit a session; pass `--session` or `OP_SESSION` when app integration is off. Prefer app integration or a service account.

## Sign out

```bash
op signout
op signout --all
```

## Diagnose

| Symptom | Fix |
|---------|-----|
| `account is not signed in` | `op whoami`; app signin or SA token |
| Wrong vault / account | `op account list`; `--account` / `OP_ACCOUNT` |
| Permission denied | SA vault grants; vault name spelling |
| Biometric / TCC spam headless | SA token + full headless block above |
| Settings / Group Containers TCC | `OP_LOAD_DESKTOP_APP_SETTINGS=false` missing in that process env |
