class Tyrionc < Formula
  desc "C bootstrap compiler for Tyrionic"
  homepage "https://github.com/tyrionic/tyrionc"
  version "0.1.0"
  license "MIT"
  release_tag = "0.1.0"

  on_macos do
    on_arm do
      url "https://github.com/tyrionic/tyrionc/releases/download/#{release_tag}/tyrionc-mac-arm64"
      sha256 "c973db10c450ae97d9a5c5b17ebb90fa3b8219bdd989fc021fe92d75bda99ec9"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/tyrionic/tyrionc/releases/download/#{release_tag}/tyrionc-linux-amd64"
      sha256 "312a53128c25143ccc6210da2c697ce377adf7f5b15bb1a480a4aae24204a2a8"
    end
    on_arm do
      url "https://github.com/tyrionic/tyrionc/releases/download/#{release_tag}/tyrionc-linux-arm64"
      sha256 "48d7e5eb3d4259bd3bc31aa3f7d050e001fda7070b0de454e474e164dc44b8c9"
    end
  end

  resource "tyrionc_source" do
    url "https://github.com/tyrionic/tyrionc/archive/refs/tags/#{release_tag}.tar.gz"
    sha256 "fbcbafe18ac21ba7f163aba31275206397a230bc60e5dc25644f2f5e4565ee41"
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
