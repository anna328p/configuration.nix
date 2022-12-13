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

		status-yellow-400 = text-warning;
		status-green-600 = text-positive;

		brand-experiment = text-brand;
		brand-experiment-560 = text-brand + "cc";
		brand-experiment-600 = text-brand + "99";
		brand-500 = text-brand;

		interactive-normal = base04;
		interactive-hover = base05;
		interactive-active = base05;
		interactive-muted = base03;

		mention-foreground = text-brand;
		mention-background = base02;

		background-primary = base01;
		background-secondary = base00;
		background-secondary-alt = base02 + "77";
		background-tertiary = base00;
		background-accent = base02;
		background-floating = base01;
		background-nested-floating = base02;

		background-mobile-primary = base01;
		background-mobile-secondary = base00;

		deprecated-card-bg = background-secondary;

		chat-background = base01;
		chat-border = base02;
		chat-input-container-background = base00;

		background-modifier-hover = base03 + "44";
		background-modifier-active = base02;
		background-modifier-selected = base02 + "cc";
		background-modifier-accent = base01;

		info-positive-background = base00;
		info-positive-foreground = text-positive;
		info-positive-text = text-normal;

		info-warning-background = base00;
		info-warning-foreground = text-warning;
		info-warning-text = text-normal;

		info-danger-background = base00;
		info-danger-foreground = text-danger;
		info-danger-text = text-normal;

		info-help-background = base00;
		info-help-foreground = base0F;
		info-help-text = text-normal;

		status-positive-background = button-positive-background;
		status-positive-text = base02;

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

		font-primary = ''
			Lexend, Whitney, "gg sans", "Noto Sans",
			"Helvetica Neue", Helvetica, Arial, sans-serif
		'';

		font-display = font-primary;
		font-headline = font-primary;

		search-popout-option-fade = "transparent";
		search-popout-option-fade-hover = "transparent";
		search-popout-option-user-nickname = text-normal;
		search-popout-option-user-username = text-muted;
		search-popout-option-filter-text = base04;
		search-popout-option-non-text-color = base03;
		search-popout-option-filter-color = base03;
		search-popout-option-answer-color = base03;

		search-popout-date-picker-border = "1px solid ${base00}cc";
		search-popout-date-picker-hint-text = base04;
		search-popout-date-picker-hint-value-text = base01;
		search-popout-date-picker-hint-value-background = text-brand;
		search-popout-date-picker-hint-value-background-hover = text-brand + "cc";
	};

	css = with lib; let
		sel = tag: prefix:
			":is(${tag}[class^='${prefix}-'], ${tag}[class*=' ${prefix}-'])";

		sel' = tag: prefixes: concatMapStrings (sel tag) prefixes;

		sels = tag: prefixes: ":is(${concatMapStringsSep ", " (sel tag) prefixes})";

		color = name: "color: ${name} !important;";
		bg = name: "background-color: ${name} !important;";

		addOpacity = fn: name: opacity: fn "${name}${opacity}";
		color' = addOpacity color;
		bg' = addOpacity bg;

		mkIdSet = names: with lib;
			listToAttrs (map (x: nameValuePair x x) names);

		tagNames = [ "span" "div" "nav" "section" "input" "button" ];

	in with mkIdSet tagNames; with formatted; ''
		:root {
			font-size: 93.75% !important;
		}

		:root, .theme-dark {
			${L.colors.genVarDecls defs}
		}

		${sel div "name"} { font-size: 15px !important; }

		code, ${sel span "inlineCode"}, ${sel div "codeLine"} {
			font-family: ${defs.font-code} !important;
			font-size: 14px !important;
		}

		${sel div "divider"} {
			border-top-color: ${base02} !important;
		}

		${sel div "checked"} { ${bg' base0B "88"} }

		${sel nav "guilds"} {
			border-right: 1px solid ${base01} !important;
		}

		${sel nav "guilds"} > ul { ${bg (byKind' "white" "black")} }

		${sel nav "guilds"} ${sel div "scrollerBase"} {
			background-color: ${base00}aa !important;
		}

		${sels div [ "autocomplete" "categoryHeader" ]} { ${bg base00} }

		${sel div "rail"} > ${sel div "list"} {
			${bg' base01 "55"}
			border-right: 1px solid ${base01};
		}

		${sel section "background"},
		${sels div ["background" "fieldList"]} { ${bg base01} }

		${sel div "homeContainer"} { ${bg' base00 "aa"} }

		${sel div "userPanelInner"} > ${sel div "scrollerBase"} {
			backdrop-filter: brightness(${byKind' "1.4" "0.55"});
		}

		${sel div "usageWrapper"} > ${sel div "option"} { ${bg base01} }

		${sel span "spoilerText"}:not(${sel span "hidden"}) { ${bg' base02 "77"} }

		${sel' span ["spoilerText" "hidden"]} { opacity: 80% }

		${sel div "chat"}, ${sel section "title"} {
			box-shadow: inset 1px 0 ${base00}66,
			            inset 1px 0 ${byKind' "white" "black"};
		}

		${sel' "*" ["colorBrand" "lookFilled"]} { ${color base01} }

		${sel div "textBadge"} { ${bg base03} }
		${sel div "akaBadge"} { ${color base00} ${bg base04} }

		${sel div "authedApp"} { ${bg base00} }

		${sel "*" "emptyStateHeader"} { ${color base05} }
		${sel "*" "emptyStateSubtext"} { ${color base06} }

		${sels div ["payment" "paymentPane" "summaryInfo" "paginator"]} {
			${bg base00} ${color base05}
		}

		${sels div ["paymentRow" "bottomDivider"]} {
			border-bottom-color: ${base01} !important;
		}

		${sels div ["pageActions" "pageButtonPrev" "pageButtonNext" "pageIndicator"]} {
			border-color: ${base02} !important;
		}

		${sel div "codeRedemptionRedirect"} {
			${color base05} ${bg base00}
			border-color: ${base02} !important;
		}

		${sels div ["bar" "markDash"]} { ${bg base02} }

		${sel div "micTest"} ${sel div "progress"} { ${bg base01} }

		${sel div "gameName"}, ${sel input "gameNameInput"} { ${color base05} }

		${sel input "gameNameInput"}:focus,
		${sel input "gameNameInput"}:hover { ${bg base00} }

		${sel' div ["card" "game"]} {
			box-shadow: 0 1px 0 0 ${base02} !important;
		}

		${sel div "nowPlayingAdd"} { ${color base04} }

		${sel div "queryContainer"} {
			${color base04} ${bg base00}
			border-bottom: 1px solid ${base02} !important;
		}

		${sel div "queryContainer"} strong { ${color base05} }

		${sel span "key"} {
			${color base00}
			${bg (byKind' base03 base04)}
			box-shadow: inset 0 -4px 0 ${(byKind' base04 base03)} !important;
		}

		${sel "*" "colorPrimary"} { ${color base05} }
		${sel button "lookLink"} { ${color base04} }

		${sel' button ["fieldButton" "lookFilled"]} { ${bg base04} ${color base00} }

		${sel div "folder"} { ${bg base01} }
		${sel span "expandedFolderBackground"} { ${bg base01} }

		${sel div "feedItemHeader"} {
			border-bottom: 1px solid ${base02}44 !important;
		}

		${sel div "headerBarInner"}::after {
			background: transparent !important;
		}

		${sel div "emojiAliasPlaceholderContent"} { ${color base05} }

		${sel div "directoryModal"} { ${bg base01} }

		${sel div "userPopoutOuter"} { backdrop-filter: blur(8px); }
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
