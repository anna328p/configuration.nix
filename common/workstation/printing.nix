{ pkgs, ... }:

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
        enable = true;
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