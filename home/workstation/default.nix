{ flakes, lib, systemConfig, ... }:

{
    imports = [
        flakes.nix-colors.homeManagerModule

        ./shell.nix
        ./ssh.nix
        ./git.nix
        ./editor.nix

        ./dconf
        ./theming

        ./audio.nix
        ./transgui.nix
    ];

    home = {
        sessionVariables = {
            NIX_AUTO_RUN = 1;
            MOZ_USE_XINPUT2 = 1;
        };
    };

    xdg = {
        enable = true;
        userDirs.enable = true;
    };

    services.fluidsynth.enable = systemConfig.misc.buildFull;

    programs.obs-studio.enable = systemConfig.misc.buildFull;

    manual.manpages.enable = lib.mkForce true;
}