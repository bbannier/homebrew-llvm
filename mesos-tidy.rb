class MesosTidy < Formula
  desc "ClangTidy for Mesos"
  homepage "https://github.com/mesos/clang-tools-extra"

  stable do
    url "https://releases.llvm.org/5.0.0/llvm-5.0.0.src.tar.xz"
    sha256 "e35dcbae6084adcf4abb32514127c5eabd7d63b733852ccdb31e06f1373136da"

    resource "clang" do
      url "https://github.com/mesos/clang.git", :branch => "mesos_50"
    end

    resource "clang-tools-extra" do
      url "https://github.com/mesos/clang-tools-extra.git", :branch => "mesos_50"
    end
  end

  keg_only :provided_by_osx

  depends_on "cmake" => :build

  fails_with :gcc_4_0
  fails_with :gcc
  ("4.3".."4.6").each do |n|
    fails_with :gcc => n
  end

  def install
    # Apple's libstdc++ is too old to build LLVM
    ENV.libcxx if ENV.compiler == :clang

    extra = "tools/clang/tools/extra"

    (buildpath/"tools/clang").install resource("clang")
    (buildpath/extra).install resource("clang-tools-extra")

    args = %w[
      -DLLVM_OPTIMIZED_TABLEGEN=ON
      -DLLVM_BUILD_LLVM_DYLIB=ON"
    ]

    mktemp do
      system "cmake", "-G", "Unix Makefiles", buildpath, *(std_cmake_args + args)
      system "cmake", "--build", extra/"clang-apply-replacements", "--target", "install"
      system "cmake", "--build", extra/"clang-tidy", "--target", "install"
    end
  end
end
