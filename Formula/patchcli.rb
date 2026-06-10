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
  url "https://storage.googleapis.com/patch-cli-dist/patchcli-1.1.1-macos.tar.gz"
  version "1.1.1"
  sha256 "0fae3644007571d64d450e8b881a6586d7234c835acf9fc6cf0ec14ed43e9098"
  license "MIT"

  # The engine shells out to `wasm-merge` / `wasm-opt` (Binaryen) during
  # `patchcli build` / `patchcli release`.
  depends_on "binaryen"
  depends_on :macos

  def install
    bin.install "patchcli"
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
    assert_match "1.1.1", shell_output("#{bin}/patchcli --version")
    assert_match "USAGE", shell_output("#{bin}/patchcli --help")
  end
end
