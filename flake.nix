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
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew,homebrew-core, homebrew-cask, homebrew-bundle, ... }:
  let
    configuration = { pkgs, config, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      nixpkgs.config.allowUnfree = true;
      environment.systemPackages =
        [ 
            pkgs.mkalias
            pkgs.neovim
            pkgs.obsidian
            pkgs.wget
            #pkgs.calibre
            pkgs.zoxide
            pkgs.yazi
            pkgs.fzf
            pkgs.go
            pkgs.gnupg
            pkgs.pinentry-tty
            pkgs.pass
            pkgs.passExtensions.pass-otp
            pkgs.yq
            pkgs.mpv
            pkgs.yt-dlp
            pkgs.ffmpeg
            pkgs.tmux
        ];
      homebrew = {
        enable = true;
          masApps = { 
            "Fantastical" = 975937182;
          };
        brews = [
            "m1-terraform-provider-helper"
            "mas"
          ];
        casks = [ 
            "selfcontrol"
            "upscayl"
            "1password"
            "1password-cli"
            "ferdium"
            "hiddenbar"
            "latest"
            "font-sf-pro"
            "iina"
            "mac-mouse-fix"
            "wezterm@nightly"
            "background-music"
            "handbrake"
            "keycastr"
            "notion"
            "termius"
            "the-unarchiver"
          ];
          #onActivation.cleanup = "zap";
      };
      fonts.packages = [
          pkgs.nerd-fonts.jetbrains-mono
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
