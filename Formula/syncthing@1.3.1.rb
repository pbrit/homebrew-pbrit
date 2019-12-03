class SyncthingAT131 < Formula
    desc "Open source continuous file synchronization application"
    homepage "https://syncthing.net/"
    url "https://github.com/syncthing/syncthing.git",
        :tag      => "v1.3.1",
        :revision => "67b8ef1f3ef419c5e9d561aa6dd88e7e1eaf9901"
    head "https://github.com/syncthing/syncthing.git"

    # Until https://github.com/syncthing/syncthing/pull/6207 is released
    patch do
      url "https://github.com/syncthing/syncthing/commit/ba7e2b23a32ed7338146e37225da414579f5c77e.patch"
      sha256 "35cb669ba2647a1dc9203dd3c50808496a92f31686a389ce22875d7da379bffd"
    end

    depends_on "go" => :build

    def install
      ENV["GOPATH"] = buildpath

      src = buildpath/"src/github.com/syncthing/syncthing"
      src.install buildpath.children
      src.cd do
        system "./build.sh", "noupgrade"
        bin.install "syncthing"
        man1.install Dir["man/*.1"]
        man5.install Dir["man/*.5"]
        man7.install Dir["man/*.7"]
        prefix.install_metafiles
      end
    end

    plist_options :manual => "syncthing"

    def plist; <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>ProgramArguments</key>
          <array>
            <string>#{opt_bin}/syncthing</string>
            <string>-no-browser</string>
            <string>-no-restart</string>
          </array>
          <key>KeepAlive</key>
          <dict>
            <key>Crashed</key>
            <true/>
            <key>SuccessfulExit</key>
            <false/>
          </dict>
          <key>ProcessType</key>
          <string>Background</string>
          <key>StandardErrorPath</key>
          <string>#{var}/log/syncthing.log</string>
          <key>StandardOutPath</key>
          <string>#{var}/log/syncthing.log</string>
        </dict>
      </plist>
    EOS
    end

    test do
      system bin/"syncthing", "-generate", "./"
    end
  end