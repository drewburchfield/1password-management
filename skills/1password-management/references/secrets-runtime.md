# Secrets runtime: read, run, inject

## Secret reference syntax

```
op://<vault>/<item>/<field>
```

Names or IDs. Quote URIs with spaces.

```bash
op read "op://Vault/Item/one-time password?attribute=otp"
```

## `op read`

```bash
op read "op://Dev Environments/myapp - API/API_KEY"
op read "op://Dev Environments/myapp - API/API_KEY" --no-newline
```

## `op run`

Resolves `op://` in the environment (and optional env file), runs a child with real secrets only for that process.

```bash
export DATABASE_URL="op://Dev Environments/myapp - DB/connection"
op run -- ./server

# .env.op (safe to commit) contains only op:// refs
op run --env-file=.env.op -- docker compose up

# Masking on by default for child stdout/stderr
op run -- printenv API_KEY
# op run --no-masking -- ...   # debug only
```

When a command expands `$VAR` that holds an `op://` reference, run the expansion in a subshell so `op run` resolves first:

```bash
op run -- sh -c 'curl -H "Authorization: Bearer $API_KEY" https://api.example.com'
```

## `op inject`

Templates use `{{ op://... }}`:

```bash
# config.yml.tpl
# db_password: {{ op://app-prod/db/password }}

op inject -i config.yml.tpl -o /tmp/config.yml
# use then delete resolved output
rm -P /tmp/config.yml 2>/dev/null || rm /tmp/config.yml

echo 'token: {{ op://V/Item/field }}' | op inject
```

Never commit resolved files.

## Env file pattern

```bash
# .env.op (git)
API_KEY=op://Dev Environments/proj - API/API_KEY
DATABASE_URL=op://Dev Environments/proj - DB/url

op run --env-file=.env.op -- npm start
```

## Service accounts

```bash
export OP_SERVICE_ACCOUNT_TOKEN="ops_..."
op whoami
op service-account ratelimit
```

See `references/auth.md` for creation and TCC env vars.

## Multi-account

```bash
op account list
op run --account work -- ./app
# or OP_ACCOUNT=work
```

## Shell plugins

```bash
op plugin list
op plugin init aws
# follow prompts; uses 1Password for CLI auth
```
