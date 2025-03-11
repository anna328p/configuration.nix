{ lib, pkgs, ... }:

{
    # PostScript interpreter for printing
    environment.systemPackages = [ pkgs.ghostscript ];

    users.users.anna.extraGroups = [
        # Allow printing/scanning
        "lp" "scanner"
    ];

    # CUPS
    services.printing = {
        enable = true;

        drivers = let p = pkgs; in [
            p.gutenprint p.gutenprintBin
            p.brlaser
            p.canon-cups-ufr2
        ];

        logLevel = "debug";
    };

    hardware.printers = {
        ensurePrinters = [
            {
                name = "Canon_MF753Cdw";
                description = "Canon MF753Cdw";

                model = "CNRCUPSMF750CZS.ppd";

                deviceUri = "http://mf753cdw.lan.ap5.network/ipp";
            }
        ];

        ensureDefaultPrinter = "Canon_MF753Cdw";
    };

    # Scanning
    hardware.sane = {
        enable = true;
        extraBackends = [ pkgs.sane-airscan ];

        brscan5 = {
            enable = true;
            
            netDevices.livingroom = {
                model = "HL-L2390DW";
                ip = "10.0.0.4";
            };
        };
    };
}