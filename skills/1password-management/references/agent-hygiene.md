# Agent hygiene

## Defaults

1. Prefer **`op run`**, **`op inject`**, **`op read`** over `op item get --reveal`.
2. Do not paste secret values into chat unless the user explicitly requests the raw secret.
3. Commit only `op://` references (or `{{ op:// }}` templates), never resolved values.
4. After `op inject`, delete the resolved file when finished (`rm -P` when available).
5. Use a **service account** for automation; do not put personal account passwords in CI.
6. Scope SA tokens to the minimum vaults.
7. Do not broadly enumerate vaults or dump all items into context.
8. For OpenClaw gateway SecretRef config, use the **openclaw-1password** plugin.

## Preferred patterns

```bash
# App needs env
export API_KEY="op://Vault/Item/API_KEY"
op run -- ./app

# One field in a script (capture carefully; avoid logging)
TOKEN=$(op read "op://Vault/Item/token" --no-newline)

# Config file
op inject -i app.toml.tpl -o /tmp/app.toml
```

## Avoid

```bash
# Avoid dumping secrets into agent-visible logs
op item get "Item" --reveal
op item get "Item" --fields password --reveal   # only if user asked for the value
```

## Confirmation

Before creating/editing vault items that store production secrets, confirm vault name and title with the user when ambiguous.
