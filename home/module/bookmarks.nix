{ config, lib, L, ... }:

with lib; let
	cfg = config.misc.bookmarks;

	mkStrOption = L.mkGenericOption {} types.str;

	bookmarkType = types.submodule {
		options = {
			name = mkStrOption "Name shown in the sidebar" { default = ""; };
			target = mkStrOption "Location that the bookmark points to" {};
		};
	};

	bookmarksType = types.listOf bookmarkType;
	strListType = types.listOf types.str;

	mkBookmarksOption = L.mkGenericOption { default = []; } bookmarksType;
	mkStrListOption = L.mkGenericOption { default = []; } strListType;
in {
	options.misc.bookmarks = {
		enable = mkEnableOption "File manager bookmarks";

		system = mkBookmarksOption "Bookmarks of paths prefixed with /" {};
		home = mkBookmarksOption "Bookmarks of paths prefixed with ~" {};
		global = mkBookmarksOption "Bookmarks of bare URIs" {};

		extraConfig = mkStrListOption "Additional bookmark lines" {};
	};

	config = mkIf cfg.enable {
		gtk.gtk3.bookmarks = with L; let
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
