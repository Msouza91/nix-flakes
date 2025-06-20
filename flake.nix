{
  description = "Marcos's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    cormacrelf-dark-notify = {
      url = "github:cormacrelf/homebrew-tap";
      flake = false;
    };
    mczachurski-homebrew-wallpapper = {
      url = "github:/mczachurski/homebrew-wallpapper";
      flake = false;
    };
    kreuzwerker-homebrew-taps = {
      url = "github:/kreuzwerker/homebrew-taps";
      flake = false;
    };
    powershell-homebrew-tap = {
      url = "github:/powershell/homebrew-tap";
      flake = false;
    };
    powerpipe-homebrew-tap = {
      url = "github:/turbot/homebrew-tap";
      flake = false;
    };
    aerospace-homebrew-tap = {
      url = "github:/nikitabobko/homebrew-tap";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew,homebrew-core, homebrew-cask, homebrew-bundle, ... }:
  let
    configuration = { pkgs, config, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      system.primaryUser = "marcos";
      nixpkgs.config.allowUnfree = true;
      environment.systemPackages =
        [ 
            pkgs.tree
            pkgs.mkalias
            pkgs.neovim
            pkgs.lazygit
            pkgs.wget
            pkgs.zoxide
            pkgs.yazi
            pkgs.fzf
            pkgs.gnupg
            pkgs.pinentry-tty
            pkgs.pass
            pkgs.passExtensions.pass-otp
            pkgs.mpv
            pkgs.yt-dlp
            pkgs.ffmpeg
            pkgs.tmux
            pkgs.stow
            pkgs.pre-commit
            pkgs.curl
            pkgs.bat
            pkgs.k9s
            pkgs.jq
            pkgs.ripgrep
            pkgs.imagemagick
            pkgs.fd
            pkgs.p7zip
            pkgs.tflint
            pkgs.terraform-docs
            pkgs.steampipe
            pkgs.steampipePackages.steampipe-plugin-aws
            pkgs.steampipePackages.steampipe-plugin-azure
            pkgs.dotnetCorePackages.dotnet_9.sdk
        ];
      homebrew = {
        enable = true;
          masApps = { 
            "Yubico Authenticator" = 1497506650;
          };
        brews = [
            "asdf"
            "awscli"
            "azure-cli"
            "borders"
            "dark-notify"
            "go" # have to install from brew because of tf helper
            "gh"
            "glow"
            "helm"
            "hugo"
            "jordanbaird-ice"
            "m1-terraform-provider-helper"
            "mas"
            "powershell"
            "pam-reattach"
            "powerpipe"
            "terragrunt"
            "sketchybar"
            "yq" # version from nixpkgs didn't work for one of my scripts
            "wallpapper"
          ];
        casks = [ 
            "anydesk"
            "aerospace"
            "ghostty"
            "1password"
            "1password-cli"
            "ferdium"
            "font-sf-pro"
            "iina"
            "keepassxc"
            "mac-mouse-fix"
            "mouseless"
            "background-music"
            "handbrake"
            "the-unarchiver"
            "monitorcontrol"
            "warp"
          ];
          onActivation.cleanup = "zap";
          onActivation.autoUpdate = true;
          onActivation.upgrade = true;
      };
      fonts.packages = [
          pkgs.maple-mono.NF
          pkgs.nerd-fonts.iosevka
          pkgs.nerd-fonts.iosevka-term
          pkgs.nerd-fonts.symbols-only
      ];

        # Make nix gui apps show up in spotlight search.
        system.activationScripts.applications.text = let
          env = pkgs.buildEnv {
            name = "system-applications";
            paths = config.environment.systemPackages;
            pathsToLink = "/Applications";
          };
        in
          pkgs.lib.mkForce ''
          # Set up applications.
          echo "setting up /Applications..." >&2
          rm -rf /Applications/Nix\ Apps
          mkdir -p /Applications/Nix\ Apps
          find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
          while read -r src; do
            app_name=$(basename "$src")
            echo "copying $src" >&2
            ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
          done
        '';
      system.defaults = {
          # dock options
          dock.autohide = true;
          dock.autohide-delay = 0.0;
          dock.autohide-time-modifier = 0.0;
          dock.orientation = "bottom";
          dock.appswitcher-all-displays = true;
          dock.showhidden = true;
          dock.mineffect = "scale";
          dock.show-recents = false;
          dock.minimize-to-application = true;
          dock.mru-spaces = false;
          dock.tilesize = 54;
          dock.persistent-apps = [
            "/Applications/Dia.app"
            "/Applications/Warp.app"
            "/System/Applications/Calendar.app"
            "/System/Applications/Messages.app"
            "/System/Applications/Mail.app"
          ];
          # finder options
          finder.ShowPathbar = true;
          finder.ShowStatusBar = true;
          finder.FXDefaultSearchScope = "SCcf";
          finder.FXEnableExtensionChangeWarning = false;
          finder.FXPreferredViewStyle = "clmv";
          finder.FXRemoveOldTrashItems = true;
          # loginwindow options
          loginwindow.LoginwindowText = "Memento Mori";
          loginwindow.PowerOffDisabledWhileLoggedIn = true;
          loginwindow.RestartDisabledWhileLoggedIn = true;
          # extras
          NSGlobalDomain.AppleICUForce24HourTime = true;
          NSGlobalDomain.AppleFontSmoothing = 2;
          NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = true;
          NSGlobalDomain.KeyRepeat = 2;
          NSGlobalDomain._HIHideMenuBar = true;
          NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
          menuExtraClock.Show24Hour = true;
          screensaver.askForPasswordDelay = 0;
          screensaver.askForPassword = true;
          trackpad.TrackpadThreeFingerDrag = true;
      };
      system = {
          keyboard.enableKeyMapping = true;
          keyboard.remapCapsLockToControl = true;
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.zsh.enable = true;
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#mac
    darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
      modules = [ 
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              # Install Homebrew under the default prefix
              enable = true;

              # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
              enableRosetta = true;

              # User owning the Homebrew prefix
              user = "marcos";

              taps = { 
                "cormacrelf/homebrew-tap" = inputs.cormacrelf-dark-notify;
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
                "mczachurski/homebrew-wallpapper" = inputs.mczachurski-homebrew-wallpapper;
                "kreuzwerker/homebrew-taps" = inputs.kreuzwerker-homebrew-taps;
                "powershell/homebrew-tap" = inputs.powershell-homebrew-tap;
                "turbot/homebrew-tap" = inputs.powerpipe-homebrew-tap;
                "nikitabobko/homebrew-tap" = inputs.aerospace-homebrew-tap;
              };

              # Automatically migrate existing Homebrew installations
              autoMigrate = true;
            };
          }
        ];
    };
    darwin-packages = self.darwinConfigurations."mac".pkgs;
  };
}
