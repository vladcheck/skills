---
name: git-sequential
description: Use when a pile of uncommitted changes (or one big commit/diff) should become a clean sequence of logical commits — incremental commits, splitting a big change, building a readable history as if the work were done step by step, staging hunks selectively before a PR.
---

# git-sequential

Turn one undifferentiated blob of changes into an ordered sequence of small, coherent commits — as if the work had been done incrementally. Goal: a history that reads as a logical progression and (ideally) builds/passes at every step.

## When to use

- You wrote everything at once but want a reviewable, story-like history.
- Splitting a big commit or diff before opening a PR.
- Want each commit to be independently understandable / bisectable.

Skip for trivial single-purpose changes — one commit is correct.

## Workflow

1. **Survey.** `git status` and `git diff` (plus `git diff --staged`). Know every changed and untracked file.
2. **Plan the order.** Sequence commits so each builds on the previous — dependencies/config first, then core/lib, then the feature that uses it, then tests, then docs. Write the list down before touching the index.
3. **Stage one step at a time:**
   - Whole file: `git add <file>`
   - Selected hunks: `git add -p` (`y`/`n` per hunk, `s` to split, `e` to hand-edit a hunk)
   - Surgical splits `-p` can't make: `git add -e` (edit the raw patch)
   - Untracked file you need to split: `git add -N <file>` first (intent-to-add), then `git add -p` can offer its hunks.
4. **Commit the step** with a message scoped to *just that step*. Repeat 3–4 until `git status` is clean.
5. **Verify:** `git log --oneline`. To prove every commit builds: `git rebase -i --exec "<test cmd>" <base>` — it stops on the first commit that fails.

## Splitting an existing single commit

```sh
git reset HEAD~          # keep changes, drop the commit; working tree now dirty
# ...then run the Workflow above
```
Mid-history commit: `git rebase -i <base>`, mark it `edit`, then `git reset HEAD^` and recommit in pieces. Reorder/squash later with the same interactive rebase.

## Quick reference

| Need | Command |
|------|---------|
| Stage hunks interactively | `git add -p` |
| Split a hunk further | `s` then `e` inside `add -p` |
| Stage part of an untracked file | `git add -N <file>` then `git add -p` |
| Hand-edit what gets staged | `git add -e` |
| Undo last commit, keep changes | `git reset HEAD~` |
| Reorder / squash / edit history | `git rebase -i <base>` |
| Assert every commit builds | `git rebase -i --exec "<cmd>" <base>` |

## Common mistakes

- **Cross-dependent hunks in separate commits.** If hunk B needs hunk A, put A's commit first or commit them together — otherwise the in-between commit is broken.
- **Forgetting untracked files.** `git add -p` ignores them until `git add -N`. Check `git status` is clean at the end.
- **Faking a history that never built.** If you care about bisectability, verify with `--exec`. If you don't, say so and skip it.
- **Rebasing pushed/shared commits** without coordinating — only rewrite history that's still local.
