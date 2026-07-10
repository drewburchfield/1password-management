---
name: 1password-management
description: >
  Use when working with 1Password CLI (op): auth and service accounts, create/read/edit items,
  secret references, op run / op inject / op read, vaults/documents, and agent-safe credential workflows.
version: 1.2.1
---

# 1Password CLI (`op`)

Auth, item CRUD, secret references, and process injection for agents and developers.

**Load on demand:**

| File | When |
|------|------|
| `references/auth.md` | Desktop, multi-account, SA, headless env block, Connect, diagnose |
| `references/agent-hygiene.md` | Must / must-not for secrets in chat and git |
| `references/item-create.md` | Field types, create/edit, tags, notes |
| `references/secrets-runtime.md` | `op run` / `inject` / `read`, env files, CI |

OpenClaw SecretRef / gateway: **openclaw-1password** plugin.

## Probe

```bash
op --version
op whoami
op account list
```

Not signed in → `references/auth.md` (app integration or service account).

## Decision table

| Goal | Action |
|------|--------|
| New API key / OAuth / DB secret | Create item (`item-create.md`) |
| Run app with secrets | `op run` + `op://` env refs |
| Render config | `op inject` |
| One field in a script | `op read "op://..."` |
| CI / agent / headless | SA + headless env block (`auth.md`) |
| Update field | `op item edit` |
| OpenClaw gateway | openclaw-1password |

## Always-on rules

1. **Quote** field assignments: `"API_KEY[password]=..."`
2. Field types (`[password]`, `[text]`, …) only on **custom** fields; not `username`, `notesPlain`, `website`
3. Always pass **`--vault`**
4. Prefer **`op run` / `op inject` / `op read`** over printing secrets into chat
5. Never dump secrets into transcripts unless the user asks for the raw value
6. Git: only `op://Vault/Item/field` (or inject templates), never resolved values
7. Multi-account: `--account` or `OP_ACCOUNT`
8. Headless SA: full block from `auth.md` (token + biometric off + no auto signin + no desktop settings)

## Auth (summary)

| Context | Method |
|---------|--------|
| Interactive + app | App CLI integration + unlock |
| Agents / CI / servers | `OP_SERVICE_ACCOUNT_TOKEN` + headless block |
| Connect | `OP_CONNECT_HOST` + `OP_CONNECT_TOKEN` |

```bash
export OP_SERVICE_ACCOUNT_TOKEN="ops_..."
export OP_BIOMETRIC_UNLOCK_ENABLED=false
export OP_NO_AUTO_SIGNIN=true
export OP_LOAD_DESKTOP_APP_SETTINGS=false
op whoami
```

## Secret references

```
op://Vault/Item/field
```

```bash
op read "op://Dev Environments/myapp - API/API_KEY"
export API_KEY="op://Dev Environments/myapp - API/API_KEY"
op run -- npm start
op inject -i config.tpl -o /tmp/config.out && rm -P /tmp/config.out 2>/dev/null
```

## Create / edit (summary)

```bash
op item create \
  --category "API Credential" \
  --title "project - service" \
  --vault "Dev Environments" \
  --tags "project,service,api" \
  "API_KEY[password]=..." \
  "website[url]=https://console.example.com" \
  "notesPlain=Usage and regenerate steps."

op item edit "project - service" "API_KEY[password]=new"
op item list --vault "Dev Environments" --tags "project"
op item get "project - service" --fields API_KEY --reveal   # only if user needs the value
```

Default category: **API Credential**. Title: `{project} - {service}`. Recipes → `item-create.md`.

Template path (no secret on argv):

```bash
op item template get "API Credential" > /tmp/item.json
# edit file
op item create --template /tmp/item.json --vault "Dev Environments"
rm -P /tmp/item.json 2>/dev/null || rm /tmp/item.json
```

## Vaults and documents

```bash
op vault list
op vault get "Dev Environments"
op document list --vault "Dev Environments"
op document get "name-or-id" --out-file ./file.bin
op document create ./file.bin --title "name" --vault "Dev Environments"
```

## Shell plugins

```bash
op plugin list
op plugin init <alias>    # e.g. aws, gh
```

## Quick reference

```bash
op whoami
op read "op://V/Item/field"
op run --env-file=.env.op -- ./app
op inject -i in.tpl -o out.cfg
op item create --category "API Credential" --title "p - s" --vault "V" "KEY[password]=..."
op item edit "p - s" "KEY[password]=..."
op service-account ratelimit
```

## Docs

- https://www.1password.dev/cli/
- https://www.1password.dev/cli/environment-variables
- https://www.1password.dev/cli/secret-references/
- https://www.1password.dev/service-accounts/
