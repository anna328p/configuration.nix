{ config, lib, L, ... }:

with lib; let
	cfg = config.misc.bookmarks;

	bookmarksType = with types; nullOr (listOf (either (str) (attrsOf str)));
	strListType = with types; nullOr (listOf str);

	mkBookmarksOption = L.mkGenericOption { default = null; } bookmarksType;
	mkStrListOption = L.mkGenericOption { default = null; } strListType;
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
			
			toBookmark = prefix: fn: entry: let
				mkTarget = val: prefix + fn val;
			in
				if isString entry
					then singleton (mkTarget entry)
					else mapAttrsToList (k: v: "${mkTarget v} ${k}") entry;

			opt' = (flip optionalsAttr') cfg;
			opt = name: fn: opt' name (concatMap fn);

		in (opt "system" (toBookmark "file://" urlencode))
		++ (opt "home" (toBookmark "file://${homeDir}/" urlencode))
		++ (opt "global" (toBookmark "" id))
		++ (opt' "extraConfig" id);
	};
}
