rec {
    ##
    # Module paths

    modulePaths.nixos = rec {
        default = local.misc;


        local = {
            misc = modules/nixos/misc;
        };

        common = {
            base = common/base;
            physical = common/physical;
            server = common/server;
            virtual = common/virtual;
            workstation = common/workstation;

            impermanent = common/impermanent;
            nginx-base = common/nginx-base;

            misc = {
                amd = common/misc/amd;
                ftp = common/misc/ftp;
                small = common/misc/small;
            };
        };

        systems = {
            hermes = systems/hermes;
            theseus = systems/theseus;

            hephaistos = systems/hephaistos;

            arachne = systems/arachne;
            angelia = systems/angelia;
            heracles = systems/heracles;
            iris = systems/iris;

            iso = systems/iso;
            generic = systems/generic;
        };
    };

    modulePaths.home = rec {
        default = local.misc;

        local = {
            misc = modules/home/misc;
        };

        module = home/module;
        base = home/base;
        workstation = home/workstation;
    };

    modulePaths.android = {
        devices = {
            aither = android/devices/aither;
        };
    };

    localModules = modulePaths.nixos // {
        inherit (modulePaths) home android;
    };
}