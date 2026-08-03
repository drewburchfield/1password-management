# Item create and edit patterns

Load when creating or restructuring 1Password items.

## Critical rules

1. **Always quote** field assignments: `"API_KEY[password]=..."`
2. Field types only on **custom** fields. Never annotate a built-in field.
3. Always pass `--vault`
4. Set the item's website with **`--url`**, not a `website[url]=` assignment
5. Pick the category whose built-ins already fit the secret (Database, SSH Key, Login) before defaulting to API Credential

## Built-in vs custom fields

Built-ins differ per category, so check before assigning rather than guessing:

```bash
op item template get "API Credential" | jq -r '.fields[].id'
```

| Category | Built-in field ids |
|----------|--------------------|
| API Credential | `notesPlain` `username` `credential` `type` `filename` `validFrom` `expires` `hostname` |
| Database | `notesPlain` `database_type` `hostname` `port` `database` `username` `password` `sid` `alias` `options` |
| Login | `username` `password` `notesPlain` |

Assign a built-in by its `id` with **no** type annotation:

```bash
"username=dbuser"          # correct: built-in
"username[text]=dbuser"    # wrong: creates a custom field shadowing the built-in
```

Anything not in the template is a custom field and **does** take a type: `"API_KEY[password]=..."`.

### Why `--url`, not `website[url]`

`website` is not a built-in on any of these categories, so `website[url]=` silently creates a custom URL field. Per 1Password's docs the `url` field type is "not used for autofill behavior" — use the `--url` flag to set the website 1Password suggests and fills for Login, Password, and API Credential items.

## Field types

| Field Type | Use Case | JSON Type |
|------------|----------|-----------|
| `password` | API keys, tokens | `CONCEALED` |
| `text` | Usernames, IDs, non-secret | `STRING` |
| `email` | Email | `EMAIL` |
| `url` | URLs | `URL` |
| `date` | YYYY-MM-DD | `DATE` |
| `monthYear` | YYYYMM or YYYY/MM | `MONTH_YEAR` |
| `phone` | Phone | `PHONE` |
| `otp` | otpauth:// URI | `OTP` |

## Pattern: Simple API key

```bash
op item create \
  --category "API Credential" \
  --title "Project - Service Name" \
  --vault "Dev Environments" \
  --tags "project,service,api" \
  --url "https://console.service.com" \
  "API_KEY[password]=your-secret-key-here" \
  "notesPlain=Brief description.

Usage: What this credential is for
Service: Container/service name

To regenerate:
1. Step one
2. Step two"
```

## Pattern: OAuth

```bash
op item create \
  --category "API Credential" \
  --title "Project - OAuth Service" \
  --vault "Dev Environments" \
  --tags "project,oauth,service" \
  --url "https://console.service.com/credentials" \
  "CLIENT_ID[text]=your-client-id" \
  "CLIENT_SECRET[password]=your-client-secret" \
  "email[email]=user@example.com" \
  "notesPlain=OAuth 2.0 credentials.

Scopes: scope1, scope2
To regenerate: console → create OAuth app → download credentials"
```

## Pattern: Database

```bash
op item create \
  --category "Database" \
  --title "Project - Database Name" \
  --vault "Dev Environments" \
  --tags "project,database,postgres" \
  --url "https://db-admin.example.com" \
  "database_type=postgresql" \
  "username=dbuser" \
  "password=secure-db-password" \
  "hostname=localhost" \
  "port=5432" \
  "database=dbname" \
  "notesPlain=PostgreSQL credentials for app/db containers."
```

## Pattern: Multi-field

```bash
op item create \
  --category "API Credential" \
  --title "Project - Complex Service" \
  --vault "Dev Environments" \
  --tags "project,service,complex" \
  --url "https://console.service.com/api" \
  "username=admin@example.com" \
  "PRIMARY_TOKEN[password]=token-abc-123" \
  "SECONDARY_TOKEN[password]=token-xyz-789" \
  "API_URL[url]=https://api.service.com" \
  "WORKSPACE_ID[text]=ws-12345" \
  "notesPlain=Multi-credential service access."
```

## Multiline notes

```bash
"notesPlain=Line 1

Line 2"
```

Or:

```bash
--notes "$(cat <<'EOF'
Line 1
Line 2
EOF
)"
```

## Title and tags

- Title: `{project} - {service}`
- Tags: project, vendor (google, aws), type (api, oauth, database), optional status (prod, staging)

## Notes template

```
{Brief one-line description}

Services: {containers}
Usage: {what it enables}

To regenerate:
1. {steps with URLs}
```

## Edit

```bash
op item edit "item-name" "NEW_FIELD[password]=value"
op item edit "item-name" "API_KEY[password]=new-value"
op item edit "item-name" --tags "a,b,c"
```

## Template create (no secrets on argv)

```bash
op item template get "API Credential" > /tmp/item.json
# fill values in the file
op item create --template /tmp/item.json --vault "Dev Environments"
rm -P /tmp/item.json 2>/dev/null || rm /tmp/item.json
```

## Create checklist

- [ ] Category (usually API Credential)
- [ ] Title `{project} - {service}`
- [ ] `--vault`
- [ ] All field assignments quoted
- [ ] Types only on custom fields (check `op item template get`)
- [ ] Website via `--url`, not `website[url]=`
- [ ] Secrets as `[password]`
- [ ] Notes with regenerate steps
- [ ] Tags: project, service, type
