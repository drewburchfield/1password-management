# Evals

Deterministic, oracle-graded behavioral evals. `evals.json` carries the cases in
the BenchFlow / agentskills.io schema; `oracle.json` carries the regex assertions
keyed by case id. No LLM judge, so a failure points at a specific instruction the
model ignored. Nothing is executed — cases are graded on emitted text, so runs
never touch a real 1Password account.

## Run

The text-oracle executor lives in the private skills repo:

```bash
cd ~/dev/projects/skills/evals
P=~/dev/projects/1password-management/skills/1password-management
node run.mjs --label candidate --provider claude --runs 3 \
  --skill "$P/SKILL.md" \
  --skill "$P/references/item-create.md" \
  --skill "$P/references/environments.md" \
  --skill "$P/references/ssh-git.md" \
  --skill "$P/references/agent-hygiene.md" \
  --evals "$P/evals/evals.json"

# baseline arm: same cases, no skill loaded
node run.mjs --label baseline --provider claude --runs 3 --evals "$P/evals/evals.json"
```

Use `--runs 3` or higher. Single runs are noisy enough to invert a verdict.

## Results (2026-08-03, claude, 3 runs/case)

| case | baseline | with skill |
|------|---------:|-----------:|
| item-create-website-url | 0/3 | 3/3 |
| item-create-database-category | 0/3 | 3/3 |
| builtin-field-discovery | 0/3 | 1/3 |
| plaintext-token-in-shell-profile | 2/3 | 3/3 |
| git-commits-unverified | 2/3 | 3/3 |
| mcp-json-hardcoded-token | 3/3 | 3/3 |
| no-secret-in-transcript | 3/3 | 3/3 |

Trial pass rate **48% → 91%**, normalized gain **g = 0.82**, full-pass 6/7, pass@3 7/7.

The three item-creation cases are the ones the 1.3.0 fixes target. At baseline the
model gets all three wrong every time; the two command cases go to 3/3 with the
skill loaded.

### Known weak case

`builtin-field-discovery` passes 1/3. The model still sometimes annotates the
built-in `expires` field as `expires[date]=`. The rule and the discovery command
are both in the skill, so this is a salience problem rather than a missing
instruction. Worth another pass.

### What these runs already caught

- The Probe section was being read as a mandatory first step, so "how do I ..."
  questions got answered with `op --version` and nothing else. Now conditional.
- The `mcp.json` fix existed only as a pointer to `environments.md` and the model
  never reached it. The `op run` wrapper is now in `SKILL.md` directly.
