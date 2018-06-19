class SfmonoSquare < Formula
  desc "Square-sized SF Mono + Japanese fonts + nerd-fonts"
  homepage "https://github.com/delphinus/homebrew-sfmono-square"
  url "https://github.com/delphinus/homebrew-sfmono-square/archive/v0.1.2018061801.tar.gz"
  sha256 "2f76835fe84847861b89e56c481fcaba87bab77dbb61be1e8a655e9dcf412b90"
  version "0.1.2018061801"

  depends_on "fontforge" => :build
  depends_on "parallel" => :build
  depends_on "python@2" => :build

  resource "sfmono" do
    url "https://github.com/ZulwiyozaPutra/SF-Mono-Font/archive/c18d1be46975d55039c3f058cf148742ddeb2723.zip"
    sha256 "d42e21f0696df0be75ea99ab669135ec5cf757b5f3fcf002abf49d284da7b0b8"
  end

  resource "migu1mfonts" do
    url "https://osdn.jp/frs/redir.php?m=gigenet&f=%2Fmix-mplus-ipa%2F63545%2Fmigu-1m-20150712.zip"
    sha256 "d4c38664dd57bc5927abe8f4fbea8f06a8ece3fea49ea02354d4e03ac6d15006"
  end

  def install
    resource("sfmono").stage { buildpath.install Dir["*"] }
    resource("migu1mfonts").stage { buildpath.install Dir["*"] }

    # generate-oblique
    system(
      "parallel", "-N3", "fontforge", "-script", buildpath/"src/generate-oblique.pe",
      ":::",
      "migu-1m-regular.ttf", "Regular", "regular",
      "migu-1m-bold.ttf",    "Bold",    "bold",
    )
    system(
      "parallel", "-N2", "fontforge", "-script", buildpath/"src/modify-migu1m.pe",
      ":::",
      "migu-1m-regular.ttf",      "modified-migu-1m-regular.ttf",
      "migu-1m-bold.ttf",         "modified-migu-1m-bold.ttf",
      "migu-1m-oblique.ttf",      "modified-migu-1m-oblique.ttf",
      "migu-1m-bold-oblique.ttf", "modified-migu-1m-bold-oblique.ttf",
    )
    system(
      "parallel", "-N2", "fontforge", "-script", buildpath/"src/modify-sfmono.pe",
      ":::",
      "SFMono-Regular.otf",       "SFMonoSquare-Regular.otf",
      "SFMono-Bold.otf",          "SFMonoSquare-Bold.otf",
      "SFMono-RegularItalic.otf", "SFMonoSquare-RegularItalic.otf",
      "SFMono-BoldItalic.otf",    "SFMonoSquare-BoldItalic.otf",
    )
    system(
      "parallel", "-N4", "fontforge", "-script", buildpath/"src/generate-sfmono-mod.pe",
      ":::",
      "SFMonoSquare-Regular.otf",       "modified-migu-1m-regular.ttf",      "Regular",     "Regular",
      "SFMonoSquare-Bold.otf",          "modified-migu-1m-bold.ttf",         "Bold",        "Bold",
      "SFMonoSquare-RegularItalic.otf", "modified-migu-1m-oblique.ttf",      "Italic",      "RegularItalic",
      "SFMonoSquare-BoldItalic.otf",    "modified-migu-1m-bold-oblique.ttf", "Bold Italic", "BoldItalic",
    )
    otfs = Dir[
      "SFMonoSquare-Regular.otf",
      "SFMonoSquare-Bold.otf",
      "SFMonoSquare-RegularItalic.otf",
      "SFMonoSquare-BoldItalic.otf",
    ].map { |f| buildpath/f }
    system(
      "parallel", "fontforge", "-lang=py", "-script",
      buildpath/"src/font-patcher", "-q", "-out", "build", "--square",
      ":::",
      *otfs,
    )
    (share/"fonts").install Dir["build/*.otf"]
  end
end
