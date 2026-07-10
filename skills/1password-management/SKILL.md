---
name: 1password-management
description: >
  Use when working with 1Password CLI (op): sign-in and service accounts, create/read/edit items,
  secret references, op run / op inject / op read, and agent-safe credential workflows.
version: 1.1.0
---

# 1Password CLI (`op`)

End-to-end credential management for agents and humans: auth, CRUD, secret references, and process injection.

**Deep patterns (load on demand):**
- `references/item-create.md` — field types, create recipes, tagging, notes templates
- `references/secrets-runtime.md` — `op run`, `op inject`, env files, CI/service accounts

For OpenClaw SecretRef wiring specifically, also use the **openclaw-1password** plugin.

## 0. Probe first

```bash
op --version
op whoami          # account type; fails if not signed in
op account list    # multi-account shorthands
```

If not signed in: desktop app integration (Settings → Developer → Integrate with 1Password CLI) then `op signin`, or set `OP_SERVICE_ACCOUNT_TOKEN` for automation.

Multi-account: `--account <shorthand|id|url>` or `OP_ACCOUNT`.

## 1. Agent hygiene (always)

1. Prefer **`op read`**, **`op run`**, **`op inject`** over printing secrets into chat.
2. Never paste secret values into transcripts unless the user explicitly asks for the raw value.
3. Prefer secret references in env files checked into git: `op://Vault/Item/field`.
4. After revealing anything sensitive, do not echo it back unprompted.
5. Headless / CI: use a **service account** scoped to the needed vaults (`OP_SERVICE_ACCOUNT_TOKEN`). Desktop biometric unlock is for interactive sessions.
6. On macOS headless `op` calls that must not pop TCC dialogs, set (when using service accounts):
   - `OP_SERVICE_ACCOUNT_TOKEN`
   - `OP_BIOMETRIC_UNLOCK_ENABLED=false`
   - `OP_NO_AUTO_SIGNIN=true`
   - `OP_LOAD_DESKTOP_APP_SETTINGS=false`

## 2. Auth ladder

| Context | Method |
|---------|--------|
| Interactive Mac with 1Password app | App integration + `op signin` / biometric |
| CI, agents, OpenClaw, servers | Service account token in env (chmod 600 file or secret store) |
| Self-hosted Connect | `OP_CONNECT_HOST` + `OP_CONNECT_TOKEN` |

```bash
# Service account verify
export OP_SERVICE_ACCOUNT_TOKEN="..."
op whoami   # Type should be SERVICE_ACCOUNT
```

Create SA in 1Password → Developer → Service Accounts; grant vault access least-privilege.

## 3. Secret references (core integration)

URI form: `op://Vault/Item/field` (names or IDs).

```bash
# Single field
op read "op://Dev Environments/myapp - API/API_KEY"

# OTP
op read "op://Private/Github/one-time password?attribute=otp"

# Env for a process (preferred for apps)
export API_KEY="op://Dev Environments/myapp - API/API_KEY"
op run -- npm start

# Config template
echo 'token: {{ op://Dev Environments/myapp - API/API_KEY }}' | op inject
```

Details: `references/secrets-runtime.md`.

## 4. Create / edit items (correctness rules)

**Always quote** field assignments (shell globs break `[` `]`):

```bash
op item create --category "API Credential" --title "proj - service" --vault "Dev Environments" \
  "API_KEY[password]=secret" "website[url]=https://console.example.com"
```

| Rule | |
|------|--|
| Quote every `field[type]=value` | Required |
| Field types (`[password]`, `[text]`, …) | Custom fields only |
| Built-ins (`username`, `notesPlain`, `website`) | No `[type]` suffix |
| Secrets | Use `[password]` / CONCEALED |
| Vault | Always pass `--vault` |

Categories for dev work: **API Credential** (default), Login, Password, Secure Note, Database.

Title convention: `{project} - {service}`. Tags: project, vendor, type (api/oauth/db).

Full recipes (OAuth, DB, multi-field, notes templates): `references/item-create.md`.

### Update

```bash
op item edit "proj - service" "API_KEY[password]=new-value"
op item edit "proj - service" --tags "proj,api,prod"
```

### Read / list

```bash
op item list --vault "Dev Environments" --tags "proj"
op item get "proj - service"                    # concealed
op item get "proj - service" --reveal           # only when needed
op item get "proj - service" --fields API_KEY --reveal
op item get "proj - service" --format json
```

Prefer `op read "op://..."` for single fields in scripts.

## 5. Templates (avoid secrets in shell history)

```bash
op item template get "API Credential" > /tmp/item.json
# edit fields in the file, then:
op item create --template /tmp/item.json --vault "Dev Environments"
rm -P /tmp/item.json 2>/dev/null || rm /tmp/item.json
```

## 6. Workflow decision

| User wants | Do |
|------------|-----|
| Store a new API key | Create item (quoted fields) + notes how to regenerate |
| Run app with secrets | `op run --` with `op://` env refs |
| Render config file | `op inject` |
| One secret in a script | `op read` |
| Agent / CI | Service account + run/inject/read; no chat dumps |
| OpenClaw gateway secrets | openclaw-1password plugin |

## 7. Quick reference

```bash
op whoami
op item create --category "API Credential" --title "p - s" --vault "V" \
  "API_KEY[password]=..." "website[url]=https://..."
op read "op://V/p - s/API_KEY"
op run --env-file=.env.tpl -- ./app
op inject -i config.tpl -o config.out
op item edit "p - s" "API_KEY[password]=..."
```

## Resources

- https://developer.1password.com/docs/cli/
- https://developer.1password.com/docs/cli/secret-references/
- https://developer.1password.com/docs/service-accounts/
