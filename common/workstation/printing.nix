{ lib, pkgs, ... }:

{
    # PostScript interpreter for printing
    environment.systemPackages = [ pkgs.ghostscript ];

    users.users.anna.extraGroups = [
        # Allow printing/scanning
        "lp" "scanner"
    ];

    # CUPS
    # can't be configured more declaratively :(
    services.printing = {
        # CVE-2024-47176, CVE-2024-47076, CVE-2024-47175, and CVE-2024-47177
        enable = lib.mkForce false;

        drivers = let p = pkgs; in [
            p.gutenprint p.gutenprintBin
            p.brlaser
        ];
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