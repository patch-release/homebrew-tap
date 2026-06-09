# Homebrew formula for the Patch CLI.
#
# The Patch engine SOURCE is private; this formula installs a pre-built,
# release, universal (arm64 + x86_64) macOS binary hosted on a public
# Google Cloud Storage bucket. New releases are published by the
# patch-cli release workflow (on a `v*` tag), which uploads the tarball
# and bumps `url` + `sha256` here.
class Patch < Formula
  desc "OTA code updates for native Swift iOS apps — auto-partitioning engine"
  homepage "https://patch.dev"
  url "https://storage.googleapis.com/patch-cli-dist/patch-1.0.1-macos.tar.gz"
  version "1.0.1"
  sha256 "cd3dff54b0398dbed16285a14c87aa09195ef7154569111e4b70e4932edec8d8"
  license "MIT"

  # The engine shells out to `wasm-merge` / `wasm-opt` (Binaryen) during
  # `patch build` / `patch release`.
  depends_on "binaryen"
  depends_on :macos

  def install
    bin.install "patch"
  end

  def caveats
    <<~EOS
      The Patch CLI is installed as `patch`.

      `patch build` / `patch release` additionally compile Swift to WebAssembly,
      which requires the swift.org toolchain + the WebAssembly SDK. That is NOT
      installable via Homebrew. Install it with swiftly:

        curl -L https://swiftlang.github.io/swiftly/install.sh | bash
        swiftly install latest
        # then install the WebAssembly SDK matching your Swift toolchain version
        # (see https://www.swift.org/documentation/articles/wasm-getting-started.html)

      Commands that do not compile WASM (init, status, channels, rollback,
      whoami, fingerprint) work without it.
    EOS
  end

  test do
    assert_match "1.0.1", shell_output("#{bin}/patch --version")
    assert_match "USAGE", shell_output("#{bin}/patch --help")
  end
end
