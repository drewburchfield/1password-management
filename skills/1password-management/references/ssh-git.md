# SSH keys, the 1Password SSH agent, and Git signing

Load for SSH key management, `Permission denied (publickey)`, commit signing setup, or signature verification failures.

The goal is that private keys never touch disk. Keys live in 1Password, the SSH agent answers requests, and you approve each one the way you unlock the app.

## Key management

Generate or import in the desktop app: **New Item > SSH Key > Add Private Key > Generate New Key**, then pick Ed25519 or RSA.

Supported: Ed25519, and RSA at 2048 / 3072 / 4096 bits, in PKCS#1, PKCS#8, or OpenSSH format.

After importing an existing key, **delete the local copy**. Developer Watchtower scans `~/.ssh` for keys still on disk and flags them.

## Turn on the agent

**Settings > Developer > Use the SSH Agent.** The agent runs inside the desktop app; there is no separate daemon to start.

Point clients at it by exporting `SSH_AUTH_SOCK`, or let 1Password configure it. On Mac the socket is under `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock`.

Not available for Flatpak or Snap installs of 1Password for Linux. Use a different install method.

Verify the agent is answering:

```bash
ssh-add -l          # lists keys the agent is offering
ssh -T git@github.com
```

`ssh-add -l` returning "The agent has no identities" usually means the app is locked or the agent toggle is off, not that the key is missing.

## Git commit signing

Requires Git 2.34+. No GPG key needed.

In the desktop app, open the SSH key > **Configure Commit Signing** > **Edit Automatically**. That writes:

| Setting | Value |
|---------|-------|
| `gpg.format` | `ssh` |
| `user.signingkey` | the chosen public key |
| `commit.gpgsign` | `true` (optional; signs without `-S`) |
| `gpg.ssh.program` | 1Password's SSH signer binary (optional; avoids setting `SSH_AUTH_SOCK` yourself) |

Or **Copy Snippet** and paste into `~/.gitconfig`. Can also be scoped to one repository.

### Register the public key with the host

Signing locally is not enough for the host to show commits as verified.

- **GitHub**: add the key with **Key type: Signing key**. An auth key is a separate entry; the same key can be registered twice, once per type.
- **GitLab**: **Usage type: Authentication & Signing**, or Signing.
- **Bitbucket**: add under SSH keys.

### Verify signatures locally

```bash
touch ~/.ssh/allowed_signers
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
```

Each line pairs an email with a trusted public key:

```
wendy@appleseed.com ssh-ed25519 AAAAC3NzaC1IZDI1NTE5AAAAIFIUXAdv5sWOrfZFEPAW8liKjBW3sFxuaNITBWwtFKO
```

Per-repository instead: `git config --local gpg.ssh.allowedSignersFile .git/allowed_signers`. The file is safe to commit, like `CODEOWNERS`.

Without it, `git log --show-signature` reports "No principal matched" even though the signature is valid.

## Multiple identities and forwarding

- Several Git identities on one machine are handled by SSH agent config rather than swapping keys in and out.
- Remote workstations, cloud dev environments, and WSL can forward SSH requests back to the agent on the local machine, so the private key stays on one device.

## Troubleshooting order

| Symptom | Check |
|---------|-------|
| `Permission denied (publickey)` | App unlocked? `ssh-add -l` lists the key? `SSH_AUTH_SOCK` set? Public key registered with the host? |
| Signing fails | Git ≥ 2.34, `gpg.format=ssh`, `user.signingkey` set, `gpg.ssh.program` points at the 1Password signer |
| Commits show unverified on the host | Key registered as a **signing** key, not only authentication |
| `No principal matched` locally | `allowed_signers` missing the author's email/key pair |
| Agent silent on Linux | Not a Flatpak or Snap install |

Full docs: `https://www.1password.dev/ssh/overview.md`
