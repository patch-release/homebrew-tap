# Homebrew formula for the Patch CLI.
#
# The Patch engine SOURCE is private; this formula installs a pre-built,
# release, universal (arm64 + x86_64) macOS binary hosted on a public
# Google Cloud Storage bucket. New releases are published by the
# patch-cli release workflow (on a `v*` tag), which uploads the tarball
# and bumps `url` + `sha256` here.
class Patchcli < Formula
  desc "OTA code updates for native Swift iOS apps — auto-partitioning engine"
  homepage "https://patchrelease.com"
  url "https://storage.googleapis.com/patch-cli-dist/patchcli-1.6.43-macos.tar.gz"
  version "1.6.43"
  sha256 "4382a9ffb29131ae2a4b55f664a05b76eebd4bdb8d34f3aa4587a68162ca6f20"
  license "MIT"

  # The engine shells out to `wasm-merge` / `wasm-opt` (Binaryen) during
  # `patchcli build` / `patchcli release`.
  depends_on "binaryen"
  depends_on :macos

  def install
    # The binary loads CodeGenerator's GuestIR templates at runtime via
    # `Bundle.module`, which resolves relative to the LAUNCHED executable's
    # directory. A plain Homebrew bin symlink would resolve to the symlink's
    # dir (where the bundle is not), so install both into libexec and put a thin
    # exec-wrapper in bin — the wrapper execs the real path, so `Bundle.module`
    # finds `Patch_CodeGenerator.bundle` sitting next to it. Without this, every
    # `patchcli build` / `release` fatals with "unable to find bundle named
    # Patch_CodeGenerator".
    libexec.install "patchcli", "Patch_CodeGenerator.bundle"
    (bin/"patchcli").write <<~SH
      #!/bin/bash
      exec "#{libexec}/patchcli" "$@"
    SH
  end

  def caveats
    <<~EOS
      Get started:

        patchcli setup    # one-time: installs the Swift→WebAssembly toolchain
        patchcli init     # in your app directory: registers the app, adds the
                          # PatchSDK package, and wires up the startup code

      `patchcli setup` is only needed for commands that compile Swift to
      WebAssembly (build / release). Everything else (init, status, channels,
      rollback, whoami, fingerprint) works without it.
    EOS
  end

  test do
    assert_match "1.6.43", shell_output("#{bin}/patchcli --version")
    assert_match "USAGE", shell_output("#{bin}/patchcli --help")
  end
end
