---
name: 1password-management
description: >
  Use when working with 1Password CLI (op): auth and service accounts, create/read/edit items,
  secret references, op run / op inject / op read, vaults/documents, and agent-safe credential workflows.
version: 1.2.0
---

# 1Password CLI (`op`)

Credential management for agents and developers: auth, item CRUD, secret references, and process injection.

**Load on demand:**
- `references/auth.md` — desktop, multi-account, service accounts, Connect, diagnose
- `references/agent-hygiene.md` — what agents must / must not do with secrets
- `references/item-create.md` — field types, create/edit recipes, tags, notes
- `references/secrets-runtime.md` — `op run`, `op inject`, `op read`, env files, CI

OpenClaw SecretRef / gateway setup: **openclaw-1password** plugin.

## Probe

```bash
op --version
op whoami
op account list
```

Not signed in → see `references/auth.md` (app integration or `OP_SERVICE_ACCOUNT_TOKEN`).

## Decision table

| Goal | Action |
|------|--------|
| New API key / OAuth / DB secret | Create item (`references/item-create.md`) |
| Run app with secrets | `op run` + `op://` env refs |
| Render config | `op inject` |
| One field in a script | `op read "op://..."` |
| CI / agent / headless | Service account + run/inject/read |
| Update field | `op item edit` |
| OpenClaw gateway | openclaw-1password |

## Always-on rules

1. **Quote** every field assignment: `"API_KEY[password]=..."`
2. Field types (`[password]`, `[text]`, …) only on **custom** fields; not on `username`, `notesPlain`, `website`
3. Always pass **`--vault`**
4. Prefer **`op run` / `op inject` / `op read`** over printing secrets into chat
5. Never dump secrets into transcripts unless the user explicitly asks for the raw value
6. Secrets in git: only `op://Vault/Item/field` (or inject templates), never resolved values
7. Multi-account: `--account` or `OP_ACCOUNT`
8. Headless SA: set token + optional TCC env (see auth.md)

## Auth (summary)

| Context | Method |
|---------|--------|
| Interactive + 1Password app | App CLI integration + unlock |
| Agents / CI / servers | `OP_SERVICE_ACCOUNT_TOKEN` |
| Connect | `OP_CONNECT_HOST` + `OP_CONNECT_TOKEN` |

```bash
export OP_SERVICE_ACCOUNT_TOKEN="ops_..."
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

Default category for dev secrets: **API Credential**. Title: `{project} - {service}`. Full recipes → `references/item-create.md`.

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
op plugin init <alias>    # e.g. aws, gh — see op plugin --help
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

- https://developer.1password.com/docs/cli/
- https://developer.1password.com/docs/cli/secret-references/
- https://developer.1password.com/docs/service-accounts/
