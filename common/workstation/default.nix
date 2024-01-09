{ localModules, ... }:

{
    imports = [
        ./udev.nix
        ./hw-support.nix
        ./storage.nix
        ./networking.nix

        ./virtualisation.nix
        ./zswap.nix
        ./kmscon.nix

        ./docs.nix

        ./sound.nix
        ./video.nix
        ./gui.nix

        ./mopidy.nix
        ./games.nix
        ./apps.nix
        ./apps-extra.nix
        ./programs.nix
    ];

    boot = {
        plymouth.enable = true;

        kernelParams = [ "iomem=relaxed" "mitigations=off" ];
    };

    # Import home configs
    home-manager = {
        users.anna.imports = [ localModules.home.workstation ];
    };

    # Don't interfere with home-manager's zsh config
    programs.zsh.promptInit = "";
}