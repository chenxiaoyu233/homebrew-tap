class AiChatSpeedBooster < Formula
  desc "Safari extension that speeds up long AI chat conversations (ChatGPT, Claude, Gemini, ...)"
  homepage "https://github.com/Noah4ever/ai-chat-speed-booster"
  url "https://github.com/Noah4ever/ai-chat-speed-booster/archive/refs/tags/v1.4.5.tar.gz"
  sha256 "c3b872012608c8341e76a0621f98200a696b8c1c51e18d00e6ce8353f611b8f8"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  head do
    url "https://github.com/Noah4ever/ai-chat-speed-booster.git", branch: "main"
  end

  depends_on "node" => :build
  depends_on :macos
  depends_on xcode: :build

  def install
    system "npm", "ci"
    system "npm", "run", "safari:setup"

    xcodeproj = "safari-app/AI Chat Speed Booster/AI Chat Speed Booster.xcodeproj"
    system "xcodebuild",
           "-project", xcodeproj,
           "-scheme", "AI Chat Speed Booster",
           "-configuration", "Release",
           "-derivedDataPath", "xcbuild",
           "CODE_SIGNING_ALLOWED=NO",
           "CODE_SIGN_IDENTITY=",
           "CODE_SIGNING_REQUIRED=NO"

    prefix.install "xcbuild/Build/Products/Release/AI Chat Speed Booster.app"
  end

  def post_install
    app = "#{prefix}/AI Chat Speed Booster.app"
    lsregister = "/System/Library/Frameworks/CoreServices.framework/" \
                 "Frameworks/LaunchServices.framework/Support/lsregister"

    quiet_system lsregister, "-f", app

    return if ENV["CI"] || ENV["GITHUB_ACTIONS"] || ENV["HOMEBREW_TEST_BOT"]

    quiet_system "/usr/bin/open", "-g", "-j", "-a", app
    sleep 2
    quiet_system "/usr/bin/osascript", "-e",
                 %(tell application id "com.noah.aichatspeedbooster" to quit)
  end

  def caveats
    <<~EOS
      First-install-only step (Safari blocks every unsigned extension until
      this toggle is on; Homebrew cannot flip it for you):

        Safari -> Settings -> Advanced -> "Show Develop menu in menu bar"
        Develop -> Developer Settings -> "Allow unsigned extensions"
        Safari -> Settings -> Extensions -> tick "AI Chat Speed Booster"

      Future `brew upgrade` runs pick up new releases automatically via the
      tap's auto-bump workflow; no further clicks needed.

      After `brew uninstall`, restart Safari once to drop the stale entry
      from Settings -> Extensions.
    EOS
  end

  test do
    app = prefix/"AI Chat Speed Booster.app"
    assert_predicate app/"Contents/Info.plist", :exist?
    bundle_id = shell_output("/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' '#{app}/Contents/Info.plist'").strip
    assert_equal "com.noah.aichatspeedbooster", bundle_id
  end
end
