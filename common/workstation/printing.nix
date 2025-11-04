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
    };
}