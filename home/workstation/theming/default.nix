{ ... }:

{
    imports = [
        ./typography.nix
        ./themes.nix
        ./gnome.nix
        ./witchhazel.nix
        ./adwaita.nix
        ./terminal.nix
        ./firefox.nix
        ./discord.nix
        ./tmux.nix
    ];

    # for testing other themes:
    # colorScheme = flakes.nix-colors.colorSchemes.solarized-light;
}