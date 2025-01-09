{ flakes, lib, ... }:

{
    imports = [
        flakes.nix-colors.homeManagerModule
        
        ./misc.nix

        ./shell.nix
        ./ssh.nix
        ./git.nix
        ./editor.nix
        ./tmux.nix

        ./programs.nix

        ./dconf
        ./theming

        ./mimeapps.nix

        ./audio.nix
    ];

    misc.buildType = "workstation";
}