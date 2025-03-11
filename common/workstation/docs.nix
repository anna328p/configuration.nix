{ pkgs, ... }:

{
    # Enable documentation globally

    environment.systemPackages = let p = pkgs; in [
        p.man-pages p.man-pages-posix p.stdman p.linux-manual
    ];

    documentation = {
        dev.enable = true;
        
        man = {
            generateCaches = true;
            
            man-db.enable = false;
            mandoc.enable = true;
        };
    };
}