# patchcli — Homebrew formula for the published tap (patch-release/tap).
#
# GENERATED FILE. Rendered from packaging/tap-formula.rb.tmpl in the patch
# monorepo by .github/workflows/cli-release.yml on every cli-v* tag and pushed to
# patch-release/homebrew-tap as Formula/patchcli.rb — edit the template, not the
# tap copy (the tap copy is overwritten by the next release).
#
# Installs a pre-built, release, universal (arm64 + x86_64) macOS binary built by
# CI from the PUBLIC tag patch-release/patch-swift@v1.7.2 and hosted on the
# public Google Cloud Storage bucket gs://patch-cli-dist.
#
# Building from source instead: packaging/patchcli.rb in the monorepo is a
# source-build formula off the same public tag (no credentials, cannot drift).
class Patchcli < Formula
  desc "OTA code updates for native Swift iOS apps — auto-partitioning engine"
  homepage "https://patchrelease.com"
  url "https://storage.googleapis.com/patch-cli-dist/patchcli-1.7.2-macos.tar.gz"
  version "1.7.2"
  sha256 "8c7bc7fd0421335aa8bece089068eb162b32723869c7b0b718328744c56a8e7e"
  # The engine is Apache-2.0. (The SDK shipped in the same repository is
  # MIT — different package, different licence.)
  license "Apache-2.0"

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
    assert_match "1.7.2", shell_output("#{bin}/patchcli --version")
    assert_match "USAGE", shell_output("#{bin}/patchcli --help")
  end
end
