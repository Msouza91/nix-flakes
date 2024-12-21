{ config, pkgs, ... }:
{
  home.username = "marcos";
  home.homeDirectory = "/home/marcos";
  home.stateVersion = "24.05";
  
  # Enable home-manager
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  # Just specify packages you want installed
  home.packages = with pkgs; [
    neovim
    stow
    git
    tree
    lazygit
    obsidian
    wget
    calibre
    zoxide
    yazi
    fzf
    gnupg
    pinentry-tty
    pass
    passExtensions.pass-otp
    mpv
    yt-dlp
    ffmpeg
    tmux
    stow
    pre-commit
    curl
    bat
    k9s
    jq
    ripgrep
    imagemagick
    fd
    p7zip
    tflint
    terraform-docs
    steampipe
    (pkgs.hiPrioSet steampipe-plugin-azure)
    steampipe-plugin-aws
    dotnetCorePackages.dotnet_9.sdk
    # Add more packages here
  ];
}

