class Quirc < Formula
  desc "QR decoder library"
  homepage "https://github.com/dlbeer/quirc"
  url "https://github.com/dlbeer/quirc/archive/v1.0.tar.gz"
  sha256 "91bba64ffca5b84aa953b88d5f5ccc9507275345c200fd581dca24fbf66b3706"
  head "https://github.com/dlbeer/quirc.git"

  option "with-sdl", "Enable the inspect utility program"

  depends_on "sdl" => :optional
  if build.with? "sdl"
    depends_on "sdl_gfx"
  end

  def install
    args = %w[
      libquirc.a
      libquirc.so
    ]

    if build.with? "sdl"
      inreplace "tests/inspect.c", "#include <SDL", "#include <SDL/SDL"

      args << "inspect"
      args << "SDL_LIBS=-lSDL -lSDLmain -framework Foundation -framework Cocoa"
    end

    system "make", *args

    Dir.glob "libquirc.so.*" do |so|
      dylib = so.sub /\.so\.(\d.+)/, ".\\1.dylib"
      mv so, dylib
      MachO::Tools.change_dylib_id(dylib, dylib)
      lib.install dylib
      lib.install_symlink dylib => "libquirc.dylib"
    end

    include.install "lib/quirc.h"
    lib.install "libquirc.a"
    bin.install "inspect" if build.with? "sdl"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <quirc.h>
      int main() {
        quirc_version();
      }
    EOS
    system ENV.cc, "test.cpp", "-L#{lib}", "-lquirc", "-o", "test"
    system "./test"
  end
end
