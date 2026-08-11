# fxblake3

**BLAKE3 integrity CLI for [fx](https://github.com/ledocorp/fxlang) projects.**

fxblake3 hashes files and simple directory trees under `--allow` (FsCap). Complements pin/repro habit; it does **not** replace `fx mod verify` / `fx.sum`. Product logic is **fx**; rebuild with `fx build … --cli`. Dual-path: emit-C and IR.

| | |
|--|--|
| **Requires** | [fx](https://github.com/ledocorp/fxlang) **0.9.6+** (with `--cli`) |
| **Platforms** | Windows + Linux **x86_64** |
| **License** | Apache-2.0 (tool) · Apache-2.0 / CC0 (BLAKE3) |
| **Org** | [LedoCorp](http://www.ledocorp.org) |

## Install (release binaries)

1. Install [fx 0.9.6+](https://github.com/ledocorp/fxlang/releases/tag/v0.9.6).  
2. Download the asset for your OS from [Releases](https://github.com/ledocorp/fxblake3/releases).  
3. Put `bin/windows/fxblake3.exe` or `bin/linux/fxblake3` on your `PATH`.

```text
# Windows (PowerShell)
Invoke-WebRequest -Uri https://github.com/ledocorp/fxblake3/releases/download/v0.1.0/fxblake3-0.1.0-windows-x86_64.zip -OutFile fxblake3.zip
Expand-Archive fxblake3.zip -DestinationPath .
.\bin\windows\fxblake3.exe --help

# Linux
curl -LO https://github.com/ledocorp/fxblake3/releases/download/v0.1.0/fxblake3-0.1.0-linux-x86_64.tar.gz
tar xzf fxblake3-0.1.0-linux-x86_64.tar.gz
./bin/linux/fxblake3 --help
```

Optional: `fxblake3-ir` is the IR dual-path binary (same CLI).

## Quick start

```text
fxblake3 --allow . abc.txt
fxblake3 --allow . --tree mydir
```

Prints `hex  path` (two spaces). Tree mode: sorted relative paths; each file contributes `relpath\0` + bytes into one hasher.

## CLI

| Invocation | Behavior |
|------------|----------|
| `fxblake3 --allow <dir> <path>` | Hash one file |
| `fxblake3 --allow <dir> --tree <dir>` | Hash directory tree |
| `fxblake3 --help` | Usage |

Exit codes: `0` ok · `1` usage · `2` path deny / missing · `3` I/O / hash failure.

## Rebuild from source

With `fx` 0.9.6+ on `PATH`, `FX_STD_ROOT` pointing at fx `std/`, and access to the BLAKE3 wrap + `host/cap`:

```text
fx build fxblake3_lib.fx -o out --emit-c --cli \
  --link <wrap_blake3>/blake3_ref.c \
  --link <wrap_blake3>/third_party/blake3_amalg.c \
  --link <host>/cap/fx_cap_runtime.c \
  --link-include <wrap_blake3>/third_party \
  --link-include <host>/cap
```

Same links with `--backend ir` for the IR binary. No author-written `host.c`.

## Non-goals (v1)

Keyed modes · HMAC theater · replacing `fx.sum` · macOS prebuilt claim · HTTP parse

## Docs

- [docs/FXBLAKE3.md](docs/FXBLAKE3.md) — design summary  
- [docs/releases/](docs/releases/) — release notes  
- Language: [ledocorp/fxlang](https://github.com/ledocorp/fxlang)

## License

Copyright Shawn Londono · LedoCorp · Apache-2.0 — see [LICENSE](LICENSE).
