{ pkgs, ... }:

{
    services.mysql = {
        enable = true;
        package = pkgs.mariadb;
        ensureDatabases = [ "boards" "iot" "rainloop" ];
        ensureUsers = [
            { name = "nobody"; ensurePermissions = {
                "boards.*"   = "ALL PRIVILEGES";
                "iot.*"      = "ALL PRIVILEGES";
                "rainloop.*" = "ALL PRIVILEGES";
            }; }
            { name = "anna";   ensurePermissions = { "iot.*" = "ALL PRIVILEGES"; }; }
            { name = "root";   ensurePermissions = { "*.*"   = "ALL PRIVILEGES"; }; }
        ];
    };
}