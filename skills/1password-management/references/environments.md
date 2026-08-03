# Environments, MCP server, and agent hooks

Load when project secrets live in a `.env`, when wiring secrets into an MCP server config, or when an agent should validate its secret setup before running commands.

Environments are in **beta** and are the current 1Password answer for project environment variables. They sit alongside vault items rather than replacing them: items are for credentials you manage individually, Environments are for the set of variables one project needs.

## Why it matters for agents

1Password's own guidance: remove plaintext API keys from `.env` files and shell profiles (`~/.zshrc`, `~/.bashrc`). A locally mounted `.env` is served through a UNIX named pipe, so the plaintext never lands on disk and never enters git.

## Requirements

- 1Password desktop app for **Mac, Windows, or Linux** (not iOS/Android)
- Local `.env` mounts, MCP, and mount validation are **Mac and Linux only**
- `op run --environment` needs the **CLI beta**; check with `op --version` before promising it

## Set up an Environment

Desktop app only; there is no `op` command to create one.

1. **Developer > View Environments > New environment**
2. Add variables: **Import .env file**, or **New variable** per key
3. **Destinations** tab > **Configure destination** > Local `.env` file > choose path > **Mount .env file**

Up to ten enabled local `.env` files per device. Values are returned exactly as entered, so quote values containing spaces (`"bar baz"`) and escape special characters (`\$100`), same as a real `.env`.

## Verify a mount

```bash
cat .env          # authorize in the prompt; contents are piped, never written
```

Authorization lasts until 1Password locks.

**Do not read a mounted path programmatically expecting a file.** It is a live FIFO. Reading it twice, or reading it with a tool that seeks, will not behave like a regular file.

If a real `.env` at that path is already tracked by git, delete it and commit the removal **before** mounting. Otherwise `git status` keeps reporting the mounted file as a change. The secrets still cannot be staged, but the noise is confusing.

Compatible with the standard dotenv libraries (Node `dotenv`, `python-dotenv` ≥ 1.1.2, Go `godotenv`, Ruby, PHP, Java, C#, Rust `dotenvy`, Docker Compose).

## MCP server config without plaintext tokens

Instead of hardcoding tokens in `mcp.json`, wrap the server in `op run`:

```json
{
  "mcpServers": {
    "example": {
      "command": "op",
      "args": ["run", "--environment", "<environmentID>", "--",
               "npx", "-y", "@example/mcp@latest"]
    }
  }
}
```

Get `<environmentID>` from **Manage environment > Copy environment ID**. Drop the `env` block entirely: `op run` injects the variables into the process, so re-declaring them is redundant. Keep `env` only for non-secret config.

GUI-launched MCP hosts (Claude Desktop on Mac) may not inherit your shell `$PATH`. If `op` is not found, use the absolute path (`/opt/homebrew/bin/op`).

## 1Password MCP server

The desktop app ships an MCP server (`1password-mcp`) for managing Environments from an MCP client, without exposing secret values to the agent.

- Enable **Settings > Labs > MCP Server** (`onepassword://settings/labs`). A missing setting means the account lacks the `ai-local-mcp-server` feature flag.
- Config: `{"mcpServers": {"1password": {"command": "1password-mcp"}}}`

The official workflow skill for these tools is vendored at [upstream/1password-environments.md](upstream/1password-environments.md). Its hard rule: an import from `.env` is not complete until `create_local_env_file` has mounted at the **source** path and `list_local_env_files` confirms it.

## Agent hook: validate mounted .env before shell commands

`1Password/agent-hooks` (MIT) officially supports Claude Code, Cursor, GitHub Copilot, and Windsurf. The hook fires before shell execution, checks that every configured mount exists as a valid enabled FIFO, and blocks with an actionable message when it does not.

```bash
git clone https://github.com/1Password/agent-hooks.git
cd agent-hooks
./install.sh --agent claude-code     # creates claude-code-1password-hooks-bundle/
```

Move the bundle into the project and point `.claude/settings.json` at `bin/run-hook.sh 1password-validate-mounted-env-files`. Scope is per-project.

Needs `sqlite3` on `PATH` (preinstalled on macOS) because it queries the 1Password database for mount entries. It **fails open**: no 1Password, no database, or no `sqlite3` means execution proceeds rather than blocking.

## Reading Environments programmatically

CLI or the Go / JavaScript / Python SDKs; see `https://www.1password.dev/environments/read-environment-variables.md`. Environments can also sync to AWS Secrets Manager.

## When not to use Environments

- Windows local mounts, or iOS/Android: unsupported
- A single credential shared across projects: use a vault item and an `op://` reference
- Headless servers and CI with no desktop app: service account plus `op run --env-file`, see [auth.md](auth.md) and [secrets-runtime.md](secrets-runtime.md)
