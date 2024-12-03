let
    inherit (import ./local-modules.nix)
        localModules modulePaths;

    inherit (localModules)
        systems common android;
in {
    nixos = rec {
        hermes = [ systems.hermes ];
        hermes-small = hermes ++ [ common.misc.small ];

        theseus = [ systems.theseus ];
        theseus-small = theseus ++ [ common.misc.small ];

        hephaistos = [ systems.hephaistos ];

        heracles = [ systems.heracles ];
        arachne = [ systems.arachne ];
        angelia = [ systems.angelia ];
        iris = [ systems.iris ];

        generic = [ systems.generic ];
        generic-small = generic ++ [ common.misc.small ];
    };

    android = {
        aither = [ android.devices.aither ];
    };
}