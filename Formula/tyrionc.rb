class Tyrionc < Formula
  desc "C bootstrap compiler for Tyrionic"
  homepage "https://github.com/tyrionic/tyrionc"
  version "0.1.1"
  license "MIT"
  release_tag = "0.1.1"

  on_macos do
    on_arm do
      url "https://github.com/tyrionic/tyrionc/releases/download/#{release_tag}/tyrionc-mac-arm64"
      sha256 "b91522df735bfe05f05a6503b3ffebb30441a1da6d242b2c7661bf0c0669caa3"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/tyrionic/tyrionc/releases/download/#{release_tag}/tyrionc-linux-amd64"
      sha256 "acf4061d89ee94dbcaa480e1414c42a1420fe5e656375c60e9cc55043e93137d"
    end
    on_arm do
      url "https://github.com/tyrionic/tyrionc/releases/download/#{release_tag}/tyrionc-linux-arm64"
      sha256 "4c0017980da4783c4af87afd9ab28b42e67b9351bcbc7c4654ab089671ecf571"
    end
  end

  resource "tyrionc_source" do
    url "https://github.com/tyrionic/tyrionc/archive/refs/tags/#{release_tag}.tar.gz"
    sha256 "13674b34f56887560ea2de2faf4b8dc777e17a57cb12c3f7cea6fcfcf299e079"
  end

  def install
    binary_name =
      if OS.mac?
        odie "tyrionc binaries currently support Apple Silicon macOS only" unless Hardware::CPU.arm?
        "tyrionc-mac-arm64"
      elsif OS.linux?
        Hardware::CPU.arm? ? "tyrionc-linux-arm64" : "tyrionc-linux-amd64"
      else
        odie "Unsupported platform for tyrionc"
      end

    source_binary = buildpath/binary_name
    odie "Expected prebuilt binary missing: #{source_binary}" unless source_binary.exist?

    bin.install source_binary => "tyrionc"
    chmod 0755, bin/"tyrionc"

    resource("tyrionc_source").stage do
      pkgshare.install "tyrionc.ty"
      pkgshare.install "compiler"
      pkgshare.install "examples/extensions" => "extensions"
    end
  end

  test do
    assert_match "tyrionc bootstrap-runtime", shell_output("#{bin}/tyrionc --version")
    assert_match "tyrionic compiler", shell_output("#{bin}/tyrionc --selfhost-cli #{pkgshare}/tyrionc.ty --version")
    assert_path_exists pkgshare/"tyrionc.ty"
    assert_path_exists pkgshare/"compiler"
    assert_path_exists pkgshare/"extensions"
    assert_path_exists pkgshare/"extensions/README.md"
    refute_path_exists bin/"tyrionic"
  end
end
