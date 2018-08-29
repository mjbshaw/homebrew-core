class Cmocka < Formula
  desc "Unit testing framework for C"
  homepage "https://cmocka.org/"
  url "https://cmocka.org/files/1.1/cmocka-1.1.2.tar.xz"
  sha256 "d11cd1e129827ff240a501c1c43557e808de89e8fcd8ab9e963c8db419332bdd"
  head "https://git.cryptomilk.org/projects/cmocka.git"

  bottle do
    cellar :any
    sha256 "5c4a778fac256d934fe4943884b23a18f9a1a4b51c3a4d8bbb0145e5cbc145d2" => :mojave
    sha256 "46556c6832c5781bf424d04a8c1a2dacf16561452eb5dbccf5e25661108ec89b" => :high_sierra
    sha256 "cfadb41736fe22bec1e1dbe87223047b8faee2a179cf0928590fbd6090f447c9" => :sierra
    sha256 "becddf7837ddaf693f3ad6ac509886a10acef70208be90570cdabe574002e767" => :el_capitan
    sha256 "f14b8b0b5e5a46dab6a5aadce80d2542ad6d153b2b416309a4f4fad819dd0199" => :yosemite
  end

  depends_on "cmake" => :build

  def install
    args = std_cmake_args
    args << "-DWITH_STATIC_LIB=ON" << "-DWITH_CMOCKERY_SUPPORT=ON" << "-DUNIT_TESTING=ON"
    if MacOS.version == "10.11" && MacOS::Xcode.installed? && MacOS::Xcode.version >= "8.0"
      args << "-DHAVE_CLOCK_GETTIME:INTERNAL=0"
    end

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdarg.h>
      #include <stddef.h>
      #include <setjmp.h>
      #include <cmocka.h>

      static void null_test_success(void **state) {
        (void) state; /* unused */
      }

      int main(void) {
        const struct CMUnitTest tests[] = {
            cmocka_unit_test(null_test_success),
        };
        return cmocka_run_group_tests(tests, NULL, NULL);
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lcmocka", "-o", "test"
    system "./test"
  end
end
