# Meticulous Machine Profile Format

This repo contains an example profile and a json schema for the meticulous profile json.

rfc.md contains a super dirty explanation which is a) unfinished and b) only public to serve as a basis for discussion.
A final and dependable version will be marked as such!

## Exit-trigger comparisons

Exit triggers support four comparison values, each with its own boundary
semantics:

- `>` activates only when the monitored value is strictly above the threshold.
- `<` activates only when the monitored value is strictly below the threshold.
- `>=` activates when the monitored value equals or exceeds the threshold.
- `<=` activates when the monitored value equals or falls below the threshold.

The `comparison` field remains optional. When it is omitted, consumers use
`>=` for compatibility with existing profiles. Explicit comparison values are
preserved as written; none of the four supported values is deprecated or
migrated to another value.

Run the dependency-free repository contract check with PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./tests/validate-contract.ps1
```
