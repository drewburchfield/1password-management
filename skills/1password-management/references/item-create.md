# Item create and edit patterns

Load when creating or restructuring 1Password items.

## Critical rules

1. **Always quote** field assignments: `"API_KEY[password]=..."`
2. Field types only on **custom** fields, not built-ins (`username`, `notesPlain`, `website`)
3. Always pass `--vault`
4. Prefer category **API Credential** for developer secrets

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
  "API_KEY[password]=your-secret-key-here" \
  "website[url]=https://console.service.com" \
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
  "CLIENT_ID[text]=your-client-id" \
  "CLIENT_SECRET[password]=your-client-secret" \
  "email[email]=user@example.com" \
  "website[url]=https://console.service.com/credentials" \
  "notesPlain=OAuth 2.0 credentials.

Scopes: scope1, scope2
To regenerate: console → create OAuth app → download credentials"
```

## Pattern: Database

```bash
op item create \
  --category "API Credential" \
  --title "Project - Database Name" \
  --vault "Dev Environments" \
  --tags "project,database,postgres" \
  "username[text]=dbuser" \
  "password[password]=secure-db-password" \
  "hostname[text]=localhost" \
  "port[text]=5432" \
  "database[text]=dbname" \
  "website[url]=https://db-admin.example.com" \
  "notesPlain=PostgreSQL credentials for app/db containers."
```

## Pattern: Multi-field

```bash
op item create \
  --category "API Credential" \
  --title "Project - Complex Service" \
  --vault "Dev Environments" \
  --tags "project,service,complex" \
  "username[text]=admin@example.com" \
  "PRIMARY_TOKEN[password]=token-abc-123" \
  "SECONDARY_TOKEN[password]=token-xyz-789" \
  "API_URL[url]=https://api.service.com" \
  "WORKSPACE_ID[text]=ws-12345" \
  "website[url]=https://console.service.com/api" \
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
- [ ] Types only on custom fields
- [ ] Secrets as `[password]`
- [ ] Notes with regenerate steps
- [ ] Tags: project, service, type
