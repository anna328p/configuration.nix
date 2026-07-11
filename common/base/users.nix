{ lib, flakes, config, specialArgs, localModules, ... }:

{
    imports = [
        flakes.home-manager.nixosModules.default
    ];

    # TODO: systemd-homed integration nixpkgs#301337
    services.userborn.enable = true;

    users = let
        sshPubKey = builtins.readFile files/ssh-public-key;

        passwdHash = "$6$o3HFaJySc0ptEcz$tr5ndkC9HMA0RDVobaLUncgzEiveeWtSJV8"
                      + "659EYdA2EnrNxB9vTrSmJVv5lAlF8nR0fu4HpBJ5e5wP02LHqq0";
    in {
        mutableUsers = false;

        users.anna = {
            description = "Anna";
            isNormalUser = true;

            uid = 1000; # consistent uid everywhere
            autoSubUidGidRange = true; # container support

            extraGroups = [ "wheel" ]; # sudo rights

            initialHashedPassword = passwdHash;

            openssh.authorizedKeys.keys = [ sshPubKey ];
        };

        users.root = {
            initialHashedPassword = lib.mkDefault passwdHash;
            openssh.authorizedKeys.keys = [ sshPubKey ];
        };
    };

    home-manager = {
        useUserPackages = true;
        useGlobalPkgs = true;

        extraSpecialArgs = specialArgs // { systemConfig = config; };

        sharedModules = [ localModules.home.base ];

        backupFileExtension = "hm-backup";
        
        users.anna = { };
    };
}