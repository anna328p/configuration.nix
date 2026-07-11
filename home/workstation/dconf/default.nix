{ lib, ... }:

{
    imports = [
        ./gnome-shell.nix
        ./gsconnect.nix
        ./weather.nix
        ./input.nix
    ];

    dconf.settings = let self = {
        "org/gnome/desktop/interface" = {
            enable-animations = false;
            gtk-enable-primary-paste = true;
        };

        "org/gnome/nautilus/preferences" = {
            default-folder-viewer = "list-view";
            show-create-link = true;
            show-delete-permanently = true;
        };

        "org/gnome/nautilus/list-view" = {
            default-zoom-level = "small";
            use-tree-view = true;
        };

        "org/gtk/settings/file-chooser" = {
            sort-directories-first = true;
            sort-column = "modified";
            sort-order = "descending";
        };

        "org/gtk/settings/debug" = {
            enable-inspector-keybinding = true;
            inspector-warning = false;
        };

        "org/gtk/gtk4/settings/debug" = self."org/gtk/settings/debug";

        "org/gtk/gtk4/settings/file-chooser" = self."org/gtk/settings/file-chooser";

        "ca/desrt/dconf-editor".show-warning = false;
    }; in self;
}