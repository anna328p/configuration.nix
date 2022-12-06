{ config, lib, ... }:

with lib; let
	cfg = config.misc;
in {
	options.misc = {
		fonts = let
			mkFontOption = description: args: mkOption (args // {
				type = hm.types.fontType;
				inherit description;
			});
		in {
			ui = mkFontOption "Font used in system applications" {};
			document = mkFontOption "Font used for documents" {};
			monospace = mkFontOption "Font used for terminals and code" {};
		};
	};

	config = let
		fontDesc = opt: "${opt.name} ${builtins.toString opt.size}";
	in {
		home.packages = let
		    optionalPackage = opt:
				optional (opt != null && opt.package != null) opt.package;
		in concatMap optionalPackage [
			cfg.fonts.ui
			cfg.fonts.document
			cfg.fonts.monospace
		];

		gtk = {
			enable = true;
			font = cfg.fonts.ui;
		};

		dconf.settings = {
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
