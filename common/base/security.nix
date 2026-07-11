{ pkgs, ... }:

{
    security = {
        sudo.enable = false;
        doas.enable = false;

        polkit.extraConfig = /* js */ ''
            // allow run0 without password for users in group wheel
            polkit.addRule(function(action, subject) {
                var id = "org.freedesktop.systemd1.manage-units";
                var group = "wheel";

                if (action.id == id && subject.isInGroup(group)) {
                    return polkit.Result.YES;
                }
            });
        '';

        allowUserNamespaces = true;
    };

    environment.systemPackages = let
        sudo-wrapper = pkgs.writeShellScriptBin "sudo" ''
            exec run0 --background= "$@"
        '';
    in [
        sudo-wrapper
    ];

    nix.settings.trusted-users = [ "root" "@wheel" ];
}