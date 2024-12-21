{ config, pkgs, ... }:
{
  home.username = "marcos";
  home.homeDirectory = "/home/marcos";
  home.stateVersion = "24.05";
  
  # Enable home-manager
  programs.home-manager.enable = true;

  # Just specify packages you want installed
  home.packages = with pkgs; [
    neofetch
    # Add more packages here
  ];
}

