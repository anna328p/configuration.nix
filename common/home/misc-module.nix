{ config, lib, L, ... }:

with lib; let
	cfg = config.misc;

	bookmarksType = with types; nullOr (listOf (either (str) (attrsOf str)));
	strListType = with types; nullOr (listOf str);

	mkGenericOption = type: defaults: description: args:
		mkOption ({ inherit type description; } // defaults // args);

	mkFontOption = mkGenericOption hm.types.fontType {};

	mkStrListOption = mkGenericOption strListType { default = null; };
	mkBookmarksOption = mkGenericOption bookmarksType { default = null; };
in {
	options.misc = {
		fonts = {
			ui = mkFontOption "Font used in system applications" {};
			document = mkFontOption "Font used for documents" {};
			monospace = mkFontOption "Font used for terminals and code" {};
		};

		bookmarks = {
			enable = mkEnableOption "File manager bookmarks";

			system = mkBookmarksOption "Bookmarks of paths prefixed with /" {};
			home = mkBookmarksOption "Bookmarks of paths prefixed with ~" {};
			global = mkBookmarksOption "Bookmarks of bare URIs" {};

			extraConfig = mkStrListOption "Additional bookmark lines" {};
		};
	};

	config = {
		home.packages = let
		    optionalPackage = opt:
				optional (opt != null && opt.package != null) opt.package;
		in concatMap optionalPackage [
			cfg.fonts.ui
			cfg.fonts.document
			cfg.fonts.monospace
		];

		gtk.enable = true;
		gtk.font = cfg.fonts.ui;

		gtk.gtk3.bookmarks = mkIf cfg.bookmarks.enable (
			let
				bcfg = cfg.bookmarks;
				homeDir = config.home.homeDirectory;

				normalizeLine = fn: line:
					if isString line
						then singleton (fn line)
						else (mapAttrsToList
							(k: v: "${fn v} ${k}")
							line);

				encodeLine' = pfx: normalizeLine (v: "${pfx}${L.urlencode v}");
				normalizeLine' = normalizeLine id;

				opt' = val: f: if (val != null) then (f val) else [];

			in (opt' bcfg.system (concatMap (encodeLine' "file://")))
			++ (opt' bcfg.home (concatMap (encodeLine' "file://${homeDir}/")))
			++ (opt' bcfg.global (concatMap normalizeLine'))
			++ (opt' bcfg.extraConfig id)
		);

		dconf.settings = let
			fontDesc = opt: "${opt.name} ${builtins.toString opt.size}";
		in {
			"org/gnome/desktop/interface" = {
				document-font-name = fontDesc cfg.fonts.document;
				monospace-font-name = fontDesc cfg.fonts.monospace;
			};

			"org/gnome/desktop/wm/preferences" = {
				titlebar-font = fontDesc cfg.fonts.ui;
			};
		};
	};
}
