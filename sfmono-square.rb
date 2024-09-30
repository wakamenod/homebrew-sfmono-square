# frozen_string_literal: true

# Formula to install the font: SF Mono Square
class SfmonoSquare < Formula
  desc "Square-sized SF Mono + Japanese fonts + nerd-fonts"
  homepage "https://github.com/delphinus/homebrew-sfmono-square"
  # url "https://github.com/delphinus/homebrew-sfmono-square/archive/v3.2.6.tar.gz"
  url "file:///Users/wakame/Projects/github/homebrew-sfmono-square"
  # sha256 "ebcde3c177b1efefbcc4b5689fe0cc456b7a3272f40cc83d9c95121a85da7a9a"
  version "3.2.6"
  # head "https://github.com/delphinus/homebrew-sfmono-square.git"

  depends_on "fontforge" => :build
  depends_on "fonttools" => :build
  depends_on "python@3.12" => :build
  depends_on "pod2man" => :build

  resource "shippori_mincho_regular" do
    url "https://github.com/google/fonts/raw/main/ofl/shipporimincho/ShipporiMincho-Regular.ttf"
    sha256 "769b5269f0f9bc6534b352c0e6bd856a566e03ff788f107191c2d835863570b2"
  end

  resource "shippori_mincho_bold" do
    url "https://github.com/google/fonts/raw/main/ofl/shipporimincho/ShipporiMincho-Bold.ttf"
    sha256 "63bc4eddc74793f671c3ab827c5175e773ffbe569d0bf50ee65375ea9e3bc286"
  end

  resource "go_fonts" do
    url "https://go.googlesource.com/image/+archive/refs/heads/master/font/gofont/ttfs.tar.gz"
    sha256 "a2a69ac17d46b1b4ae8c28b2077e2b626dd02d03f9f6466d38c456f65cf676b7"
  end

  def install
    _stage
    _compile

    (share / "fonts").install Dir["build/*.otf"]
    (share / "fonts/src").install Dir["*.otf"]
    (share / "fonts/src").install Dir["*.ttf"]

    dir = "script/convert_codepoints"
    system "#{Formula['pod2man'].opt_bin}/pod2man", "#{dir}/convert_codepoints", "#{dir}/convert_codepoints.1"
    bin.install "#{dir}/convert_codepoints"
    man1.install "#{dir}/convert_codepoints.1"
  end

  def _stage
    resource("shippori_mincho_regular").stage { buildpath.install Dir["*.ttf"] }
    resource("shippori_mincho_bold").stage { buildpath.install Dir["*.ttf"] }

    resource("go_fonts").stage do
      system "tar", "-xvf", "ttfs.tar.gz"
      buildpath.install Dir["*"]
    end
  end

  # Uncomment and change this value to enlarge glyphs from Migu1M.
  def _compile
    # Uncomment and change this value to enlarge glyphs from Migu1M.
    # See https://github.com/delphinus/homebrew-sfmono-square/issues/9
    # ENV["MIGU1M_SCALE"] = "82"

    fontforge_lib = Formula["fontforge"].libexec / "lib/python3.12/site-packages"
    fonttools_lib = Formula["fonttools"].libexec / "lib/python3.12/site-packages"
    python312 = Formula["python@3.12"].bin / "python3.12"

    system python312, "-c", <<~PYTHON
      import sys
      sys.path.append('#{buildpath / 'src'}')
      sys.path.append('#{fontforge_lib}')
      sys.path.append('#{fonttools_lib}')
      import build
      sys.exit(build.build('#{version}'))
    PYTHON
  end
end
