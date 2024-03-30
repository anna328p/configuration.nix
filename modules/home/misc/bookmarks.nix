{ config, L, lib, local-lib, ... }:

let
    inherit (lib) 
        types
        mkEnableOption
        mkIf
        ;

    inherit (builtins)
        baseNameOf
        isString
        ;

    inherit (local-lib) mkGenericOption;

    cfg = config.misc.bookmarks;


    mkStrOption = mkGenericOption {} types.str;

    tBookmark = types.submodule ({ config, ... }: {
        options = {
            name = mkStrOption "Name shown in the sidebar" {
                default = baseNameOf config.target;
            };

            target = mkStrOption "Location that the bookmark points to" { };
        };
    });

    coerceEntry = entry:
        if isString entry
            then { target = entry; }
            else entry;

    tBookmarkEntry = types.coercedTo
        (types.either tBookmark types.str)
        coerceEntry
        tBookmark;

    tBookmarks = types.listOf tBookmarkEntry;
    tStrList = types.listOf types.str;

    mkBookmarksOption = mkGenericOption { default = []; } tBookmarks;
    mkStrListOption = mkGenericOption { default = []; } tStrList;

in {
    options.misc.bookmarks = {
        enable = mkEnableOption "File manager bookmarks";

        system = mkBookmarksOption "Bookmarks of paths prefixed with /" {};
        home = mkBookmarksOption "Bookmarks of paths prefixed with ~" {};
        global = mkBookmarksOption "Bookmarks of bare URIs" {};

        extraConfig = mkStrListOption "Additional bookmark lines" {};
    };

    config = mkIf cfg.enable {
        gtk.gtk3.bookmarks = let
            inherit (L)
                id
                urlencode
                ;

            homeDir = config.home.homeDirectory;
            
            mkBookmarks = opt: prefix: fn: let
                mkLine = entry: let
                    inherit (entry) name target;
                in
                    "${prefix}${fn target} ${name}";
            in
                map mkLine opt;

        in (mkBookmarks cfg.system "file://"            urlencode)
        ++ (mkBookmarks cfg.home   "file://${homeDir}/" urlencode)
        ++ (mkBookmarks cfg.global ""                   id)
        ++ cfg.extraConfig;
    };
}