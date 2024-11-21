{ pkgs, ... }:

{
    services.mysql = {
        enable = true;
        package = pkgs.mariadb;
        ensureDatabases = [ "boards" "iot" ];
        ensureUsers = [
            { name = "nobody"; ensurePermissions = {
                "boards.*" = "ALL PRIVILEGES";
                "iot.*"    = "ALL PRIVILEGES";
            }; }
            { name = "anna";   ensurePermissions = { "iot.*" = "ALL PRIVILEGES"; }; }
            { name = "root";   ensurePermissions = { "*.*"   = "ALL PRIVILEGES"; }; }
        ];
    };
}