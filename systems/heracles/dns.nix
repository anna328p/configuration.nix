{ ... }:

{
    services.bind = {
        enable = true;

        cacheNetworks = [
            "10.0.0.0/8"
        ];

        zones."ipa.ap5.network" = {
            master = true;

        };
    };
}