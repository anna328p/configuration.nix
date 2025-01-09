{ lib, ... }:

{
    home = {
        sessionVariables = {
            NIX_AUTO_RUN = 1;
            MOZ_USE_XINPUT2 = 1;
        };
    };

    xdg.enable = true;

    xdg.userDirs = {
        enable = true;
        createDirectories = true;
    };

    manual.manpages.enable = lib.mkForce true;
}