{ pkgs, ... }:

{
    programs.git = {
        package = pkgs.gitAndTools.gitFull;

        userName = "Anna Kudriavtsev";
        userEmail = "anna328p@gmail.com";
    };
}
