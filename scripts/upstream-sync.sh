#!/usr/bin/env bash
# Refresh the vendored upstream payload of the 1password-management skill.
#
#   scripts/upstream-sync.sh            # sync, then show what changed
#   scripts/upstream-sync.sh --check    # report drift, change nothing (exit 1 if drift)
#
# Everything under references/upstream/ is a mechanical copy of an upstream file
# listed in references/upstream/upstream.manifest. The only transform is link rewriting: the
# upstream docs link to each other using their original one-skill-per-directory
# layout, and those paths are remapped onto our flat references/ names. The
# transform is a pure function of the manifest, so both sides of a comparison go
# through it and `git diff` after a sync shows upstream's changes and nothing
# else.
#
# skills/1password-management/SKILL.md is ours and is never touched here, so an upstream refresh can
# never conflict with our own guidance. Put local knowledge there, never in
# references/upstream/.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$REPO_ROOT/skills/1password-management/references/upstream/upstream.manifest"
REFDIR="$REPO_ROOT/skills/1password-management/references/upstream"
STAMP="$REPO_ROOT/skills/1password-management/references/upstream/UPSTREAM.md"

CHECK_ONLY=0
[[ "${1:-}" == "--check" ]] && CHECK_ONLY=1

[[ -f "$MANIFEST" ]] || { echo "missing manifest: $MANIFEST" >&2; exit 1; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# Clone each distinct repo once, shallow and blobless.
declare -a REPOS=()
while IFS=$'\t' read -r repo _ _; do
  [[ -z "$repo" || "$repo" == \#* || "$repo" == "@alias" ]] && continue
  case " ${REPOS[*]:-} " in *" $repo "*) ;; *) REPOS+=("$repo") ;; esac
done < "$MANIFEST"

: > "$WORK/shas.tsv"
for repo in "${REPOS[@]}"; do
  slug="$(basename "$repo" .git)"
  echo "fetching $repo" >&2
  git clone --depth 1 --filter=blob:none --quiet "$repo" "$WORK/$slug"
  printf '%s\t%s\n' "$slug" "$(git -C "$WORK/$slug" rev-parse HEAD)" >> "$WORK/shas.tsv"
done

mkdir -p "$REFDIR"

# Copy (unless --check) and report one "STATUS<TAB>dest<TAB>note" line per entry.
python3 - "$MANIFEST" "$WORK" "$REFDIR" "$CHECK_ONLY" > "$WORK/result.tsv" <<'PY'
import os, posixpath, re, sys

manifest, work, refdir = sys.argv[1], sys.argv[2], sys.argv[3]
check_only = sys.argv[4] == "1"

entries, aliases = [], []
for line in open(manifest, encoding="utf-8"):
    line = line.rstrip("\n")
    if not line.strip() or line.lstrip().startswith("#"):
        continue
    first, src, dest = line.split("\t")
    if first == "@alias":
        slug, _, path = src.partition(":")
        aliases.append((slug, path, dest))
    else:
        entries.append((os.path.basename(first).removesuffix(".git"), src, dest))

# (slug, normalized path in repo) -> our flat filename. Aliases are link targets
# only: they resolve a cross-reference without contributing a copied file.
index = {(slug, posixpath.normpath(src)): dest for slug, src, dest in entries}
index.update({(slug, posixpath.normpath(src)): dest for slug, src, dest in aliases})
LINK = re.compile(r"(?<=\]\()([^)\s]+\.md)(?=\))")

for slug, src, dest in entries:
    frm = os.path.join(work, slug, src)
    to = os.path.join(refdir, dest)

    if not os.path.isfile(frm):
        print(f"GONE\t{dest}\t{slug}/{src} no longer exists upstream; fix the manifest")
        continue

    base = posixpath.dirname(src)
    unresolved = []

    def remap(m):
        target = m.group(1)
        if target.startswith(("http://", "https://", "#", "/")):
            return target
        key = (slug, posixpath.normpath(posixpath.join(base, target)))
        if key in index:
            return index[key]
        unresolved.append(target)
        return target

    new = LINK.sub(remap, open(frm, encoding="utf-8").read())
    old = open(to, encoding="utf-8").read() if os.path.isfile(to) else None
    note = "links outside the vendored set: " + ", ".join(sorted(set(unresolved))) if unresolved else ""

    if old == new:
        print(f"SAME\t{dest}\t{note}")
        continue
    if not check_only:
        with open(to, "w", encoding="utf-8") as fh:
            fh.write(new)
    print(f"{'DRIFT' if check_only else 'UPDATED'}\t{dest}\t{note}")
PY

# Surface anything that links outside the vendored set: either the manifest is
# missing a file upstream now points at, or upstream added a genuinely new doc.
awk -F'\t' 'NF>2 && $3!=""{printf "  note: %s (%s)\n", $2, $3}' "$WORK/result.tsv"

if (( CHECK_ONLY )); then
  if grep -qE '^(DRIFT|GONE)' "$WORK/result.tsv"; then
    awk -F'\t' '/^(DRIFT|GONE)/{printf "%-7s %s\n", $1, $2}' "$WORK/result.tsv"
    echo "upstream drift detected; run without --check to pull it in"
    exit 1
  fi
  echo "no drift: vendored payload matches upstream"
  exit 0
fi

awk -F'\t' '/^UPDATED/{print "updated: " $2}' "$WORK/result.tsv"
updated=$(grep -c '^UPDATED' "$WORK/result.tsv" || true)

# Record provenance. Rewritten every sync so the SHAs never go stale.
{
  echo "# Upstream provenance"
  echo
  echo "Generated by \`scripts/upstream-sync.sh\`. Do not edit by hand."
  echo
  echo "Vendored from 1Password's official Cursor plugin under the MIT License."
  echo "Copyright (c) 1Password. See https://github.com/1Password/cursor-plugin."
  echo
  echo "\`references/upstream/\` mirrors upstream; the only transform is remapping"
  echo "cross-document links onto our flat filenames. Our own guidance lives in \`../../SKILL.md\`."
  echo
  echo "- Refresh: \`scripts/upstream-sync.sh\`, read the \`git diff\`, commit."
  echo "- Audit without changing anything: \`scripts/upstream-sync.sh --check\`."
  echo
  echo "## Sources"
  echo
  while IFS=$'\t' read -r slug sha; do
    echo "- \`$slug\` @ \`$sha\`"
  done < "$WORK/shas.tsv"
  echo
  echo "## Files"
  echo
  echo "| reference | upstream |"
  echo "|-----------|----------|"
  while IFS=$'\t' read -r repo src dest; do
    [[ -z "$repo" || "$repo" == \#* || "$repo" == "@alias" ]] && continue
    echo "| \`references/$dest\` | \`$(basename "$repo" .git)/$src\` |"
  done < "$MANIFEST"
} > "$STAMP"

if [[ "$updated" == "0" ]]; then
  echo "already up to date"
else
  echo
  echo "$updated file(s) updated. Review with: git -C $REPO_ROOT diff skills/"
fi
