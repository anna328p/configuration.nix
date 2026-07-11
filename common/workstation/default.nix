{ localModules, ... }:

{
    imports = [
        ./udev.nix
        ./hw-support.nix
        ./storage.nix
        ./networking.nix
        ./printing.nix

        ./virtualisation.nix
        ./zswap.nix
        ./kmscon.nix

        ./docs.nix

        ./audio.nix
        ./video.nix
        ./gui.nix
        ./rygel.nix

        ./mopidy.nix
        ./games.nix
        ./apps.nix
        ./apps-extra.nix
        ./programs.nix
        ./devtools.nix
        ./radio.nix
    ];

    # Import home configs
    home-manager.users.anna.imports = [ localModules.home.workstation ];

    # Don't interfere with home-manager's zsh config
    programs.zsh.promptInit = "";
}