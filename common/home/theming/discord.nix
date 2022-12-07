{ lib, config, pkgs, pkgsMaster, L, ... }:

let
	scheme = config.colorScheme;

	byKind' = L.colors.byKind scheme.kind;

	formatted = L.colors.prefixHash scheme.colors;

	defs = with formatted; rec {
		header-primary = base05;
		header-secondary = base06;

		text-normal = base05;
		text-muted = base04;
		text-link = base0C;
		text-link-low-saturation = base0C;

		text-positive = base0B;
		text-warning = base0A;
		text-danger = base09;
		text-brand = base0E;

		brand-experiment = text-brand;
		brand-experiment-560 = text-brand + "cc";
		brand-experiment-600 = text-brand + "99";
		brand-500 = text-brand;

		white-500 = text-normal;

		interactive-normal = base04;
		interactive-hover = base05;
		interactive-active = base05;
		interactive-muted = base03;

		mention-foreground = text-brand;
		mention-background = base02;

		background-primary = base01;
		background-secondary = base00;
		background-secondary-alt = base02 + "aa";
		background-tertiary = base00;
		background-accent = base02;
		background-floating = base02;
		background-nested-floating = base03;

		background-mobile-primary = base01;
		background-mobile-secondary = base00;

		chat-background = base01;
		chat-border = base02;
		chat-input-container-background = base00;

		background-modifier-hover = base01;
		background-modifier-active = base02;
		background-modifier-selected = base02 + "cc";
		background-modifier-accent = base01;

		info-positive-background = base02;
		info-positive-foreground = text-positive;
		info-positive-text = text-normal;

		info-warning-background = base02;
		info-warning-foreground = text-warning;
		info-warning-text = text-normal;

		info-danger-background = base02;
		info-danger-foreground = text-danger;
		info-danger-text = text-normal;

		info-help-background = base02;
		info-help-foreground = base0F;
		info-help-text = text-normal;

		status-positive-background = text-positive;
		status-positive-text = text-normal;

		status-warning-background = text-warning;
		status-warning-text = text-normal;

		status-danger-background = text-danger;
		status-danger-text = text-normal;

		status-positive = text-positive;
		status-warning = text-warning;
		status-danger = text-danger;

		button-danger-background = text-danger + "bb";
		button-danger-background-hover = text-danger + "dd";
		button-danger-background-active = text-danger;
		button-danger-background-disabled = text-danger + "99";

		button-positive-background = text-positive + "bb";
		button-positive-background-hover = text-positive + "dd";
		button-positive-background-active = text-positive;
		button-positive-background-disabled = text-positive + "99";

		button-secondary-background = base02 + "bb";
		button-secondary-background-hover = base02 + "dd";
		button-secondary-background-active = base02;
		button-secondary-background-disabled = base02 + "99";

		button-outline-danger-text = text-normal;
		button-outline-danger-text-hover = text-normal;
		button-outline-danger-text-active = text-normal;
		button-outline-danger-background = "#00000000";
		button-outline-danger-border            = text-danger;
		button-outline-danger-background-hover  = text-danger + "cc";
		button-outline-danger-border-hover      = text-danger + "cc";
		button-outline-danger-background-active = text-danger;
		button-outline-danger-border-active     = text-danger;

		button-outline-positive-text = text-normal;
		button-outline-positive-text-hover = text-normal;
		button-outline-positive-text-active = text-normal;
		button-outline-positive-background = "#00000000";
		button-outline-positive-border            = text-positive;
		button-outline-positive-background-hover  = text-positive + "cc";
		button-outline-positive-border-hover      = text-positive + "cc";
		button-outline-positive-background-active = text-positive;
		button-outline-positive-border-active     = text-positive;

		button-outline-brand-text = text-normal;
		button-outline-brand-text-hover = text-normal;
		button-outline-brand-text-active = text-normal;
		button-outline-brand-background = "#00000000";
		button-outline-brand-border            = text-brand;
		button-outline-brand-background-hover  = text-brand + "cc";
		button-outline-brand-border-hover      = text-brand + "cc";
		button-outline-brand-background-active = text-brand;
		button-outline-brand-border-active     = text-brand;

		button-outline-primary-text = text-normal;
		button-outline-primary-text-hover = text-normal;
		button-outline-primary-text-active = text-normal;
		button-outline-primary-background = "#00000000";
		button-outline-primary-border            = background-accent;
		button-outline-primary-background-hover  = background-accent + "cc";
		button-outline-primary-border-hover      = background-accent + "cc";
		button-outline-primary-background-active = background-accent;
		button-outline-primary-border-active     = background-accent;

		modal-background = background-primary;
		modal-footer-background = background-secondary;

		scrollbar-thin-thumb = base01;

		scrollbar-auto-thumb = base00;
		scrollbar-auto-track = base00 + "88";
		scrollbar-auto-scrollbar-color-thumb = base00;
		scrollbar-auto-scrollbar-color-track = base00 + "88";

		input-background = base00;
		input-placeholder-text = base03;

		channels-default = base04;
		channel-icon = base04 + "99";

		channel-text-area-placeholder = input-placeholder-text;
		channeltextarea-background = input-background;

		activity-card-background = background-secondary;
		
		textbox-markdown-syntax = base03;

		spoiler-hidden-background = base00;
		spoiler-revealed-background = base02;

		font-code = config.misc.fonts.monospace.name;

		font-primary = "Lexend";
		font-display = "Lexend";
		font-headline = "Lexend";
	};

	css = let
		sel = tag: prefix:
			":is(${tag}[class^='${prefix}-'], ${tag}[class*=' ${prefix}-'])";

		mkIdSet = names: with lib;
			listToAttrs (map (x: nameValuePair x x) names);

		tagNames = [ "span" "div" "nav" ];

	in with mkIdSet tagNames; ''
		:root {
			${L.colors.genVarDecls defs}
			font-size: 93.75% !important;
		}

		${sel div "name"} { font-size: 15px !important; }

		code, ${sel span "inlineCode"}, ${sel div "codeLine"} {
			font-family: ${defs.font-code} !important;
			font-size: 14px !important;
		}

		${sel div "divider"} {
			border-top-color: ${formatted.base02} !important;
		}

		${sel div "checked"} {
			background-color: ${formatted.base0B}88 !important;
		}

		${sel nav "guilds"} {
			border-right: 1px solid ${formatted.base01} !important;
		}

		${sel nav "guilds"} > ul {
			background-color: ${byKind' "#FFFFFF" "#000000"} !important;
		}

		${sel nav "guilds"} ${sel div "scrollerBase"} {
			background-color: ${formatted.base00}bb !important;
		}
	'';
in {
	home.packages = with pkgs; [ lexend ];

	programs.discocss = {
		enable = true;
		discordPackage = (pkgs.wrapDiscord pkgsMaster.discord);

		inherit css;
	};

	xdg.configFile."discord/settings.json".text = ''
		{
			"SKIP_HOST_UPDATE": true,
			"DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOURE_DOING": true
		}
	'';

}
