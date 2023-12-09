{ L, pkgs, flakes, config, specialArgs, localModules, ... }:

let
    passwdHash = "$6$o3HFaJySc0ptEcz$tr5ndkC9HMA0RDVobaLUncgzEiveeWtSJV8"
                  + "659EYdA2EnrNxB9vTrSmJVv5lAlF8nR0fu4HpBJ5e5wP02LHqq0";
    
    sshPubKey = "ssh-ed25519 " +
        "AAAAC3NzaC1lZDI1NTE5AAAAINifLOccm6ZB+yCka9dNYGOGHqegiA89/xXjno7g6jF7";
in {
    imports = [
        flakes.home-manager.nixosModule
    ];

    users = {
        mutableUsers = false;
        defaultUserShell = pkgs.zsh;

        users.anna = let
            # consistent uid everywhere
            uid = 1000;

            # container support
            subIdOffset = uid * (L.pow2 16);
            subIdWidth = (L.pow2 16) - 1;
        in {
            description = "Anna";
            isNormalUser = true;

            inherit uid;

            # container support
            subUidRanges = [ { startUid = subIdOffset; count = subIdWidth; } ];
            subGidRanges = [ { startGid = subIdOffset; count = subIdWidth; } ];

            # sudo rights
            extraGroups = [ "wheel" ];

            initialHashedPassword = passwdHash;

            openssh.authorizedKeys.keys = [ sshPubKey ];
        };

        users.root.initialHashedPassword = passwdHash;
        users.root.openssh.authorizedKeys.keys = [ sshPubKey ];
    };

    home-manager = {
        useUserPackages = true;
        useGlobalPkgs = true;

        extraSpecialArgs = specialArgs // { systemConfig = config; };

        sharedModules = [ localModules.home.base ];
        
        users.anna = { };
    };

    security = {
        # https://xkcd.com/1200
        sudo.wheelNeedsPassword = false;

        allowUserNamespaces = true;
    };

    nix.settings.trusted-users = [ "root" "@wheel" ];
}