class Trojan < Formula
  desc "Unidentifiable mechanism that helps you bypass GFW"
  homepage "https://trojan-gfw.github.io/trojan/"
  version "1.15.1"
  url "https://github.com/trojan-gfw/trojan/archive/v1.15.1.tar.gz"
  sha256 "ab5ed59573085e69164dce677656951d502ee6cdf0890137f6868da7af3c0ffd"
  depends_on "cmake" => :build
  depends_on "coreutils" => :test
  depends_on "python" => :test
  depends_on "boost"
  depends_on "openssl@1.1"

  def install
    inreplace "CMakeLists.txt", "server.json", "client.json"
    inreplace "examples/client.json-example", "cert\": \"", "cert\": \"/etc/ssl/cert.pem"
    system "cmake", ".", *std_cmake_args, "-DENABLE_MYSQL=OFF"
    system "make", "install"
  end

  plist_options :manual => "trojan -c #{HOMEBREW_PREFIX}/etc/trojan/config.json"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <true/>
        <key>RunAtLoad</key>
        <true/>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{bin}/trojan</string>
          <string>-c</string>
          <string>#{etc}/trojan/config.json</string>
        </array>
      </dict>
    </plist>
  EOS
  end

  test do
    resource "test" do
      url "https://github.com/trojan-gfw/trojan/archive/v1.15.1.tar.gz"
      sha256 "ab5ed59573085e69164dce677656951d502ee6cdf0890137f6868da7af3c0ffd"
    end
    resource("test").stage do
      inreplace "tests/LinuxSmokeTest/basic.sh", "openssl", "/usr/local/opt/openssl@1.1/bin/openssl"
      inreplace "tests/LinuxSmokeTest/fake-client.sh", "openssl", "/usr/local/opt/openssl@1.1/bin/openssl"
      system "sh", "-c", "cd tests/LinuxSmokeTest && ./basic.sh #{bin}/trojan"
      system "sh", "-c", "cd tests/LinuxSmokeTest && ./fake-client.sh #{bin}/trojan"
    end
  end
end
