# Patch — Homebrew tap

Official Homebrew tap for the **Patch CLI** — OTA code updates for native Swift
iOS apps (auto-partitioning engine).

```sh
brew install patch-release/tap/patch
```

This installs a signed, release-built `patch` binary (the Patch engine source is
private; only the compiled binary is distributed here).

## What gets installed

- `patch` — the CLI (`patch --help`, `patch --version`).
- A runtime dependency on **Binaryen** (`wasm-merge` / `wasm-opt`), which the
  engine shells out to during `patch build` / `patch release`.

## Additional requirement for `patch release` (not brew-installable)

Compiling Swift **to** WebAssembly needs the swift.org toolchain + the
WebAssembly SDK. That is not available via Homebrew. Install it with
[`swiftly`](https://www.swift.org/install/):

```sh
curl -L https://swiftlang.github.io/swiftly/install.sh | bash
swiftly install latest
# then add the WebAssembly SDK that matches your Swift toolchain:
#   swift sdk install <wasm-sdk-url-for-your-swift-version>
```

`patch init`, `patch status`, `patch channels`, `patch rollback`, etc. work
without it; only the WASM compile path (`patch build` / `patch release`) needs
the WASM SDK.
