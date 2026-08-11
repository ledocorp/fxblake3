# fxblake3 — user design summary

fxblake3 is a **BLAKE3 integrity CLI**: hash a file or a simple directory tree under `--allow` (FsCap). Output is `hex  path` (b3sum-like).

## Why fxblake3

| Keep | Refuse (v1) |
|------|-------------|
| Official BLAKE3 portable C | Crypto-marketing theater |
| Required `--allow` | Ambient filesystem |
| File + sorted `--tree` digest | Keyed / derive modes in v1 |
| Complements `fx.sum` habit | Replacing `fx mod verify` |
| Dual-path emit-C + IR | Optional-IR theater |

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | ok |
| 1 | usage / bad flags |
| 2 | path deny / missing |
| 3 | I/O / hash failure |

## Rebuild

See root README. Needs fx 0.9.6+ with `--cli`, `host/cap`, and BLAKE3 1.5.5 portable amalgamation.

## Non-goals

Keyed modes · replacing `fx.sum` · macOS claim · HTTP parse
