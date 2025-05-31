{ lib, config, pkgs, local-lib, ... }:

let
    inherit (local-lib) colors;

    scheme = config.colorScheme;

    byVariant' = colors.byVariant scheme.variant;

    formatted = colors.prefixHash scheme.palette;

    defs = let c = formatted; in rec {
        header-primary = c.base05;
        header-secondary = c.base06;

        text-normal = c.base05;
        text-muted = c.base04;
        text-link = c.base0C;
        text-link-low-saturation = c.base0C;

        text-positive = c.base0B;
        text-warning = c.base0A;
        text-danger = c.base09;
        text-brand = c.base0E;

        status-yellow-400 = text-warning;
        status-green-600 = text-positive;

        brand-experiment = text-brand;
        brand-experiment-560 = text-brand + "cc";
        brand-experiment-600 = text-brand + "99";
        brand-500 = text-brand;

        interactive-normal = c.base04;
        interactive-hover = c.base05;
        interactive-active = c.base05;
        interactive-muted = c.base03;

        mention-foreground = text-brand;
        mention-background = c.base02;

        background-primary = c.base01;
        background-secondary = c.base00;
        background-secondary-alt = c.base02 + "77";
        background-tertiary = c.base00;
        background-accent = c.base02;
        background-floating = c.base01;
        background-nested-floating = c.base02;

        background-mobile-primary = c.base01;
        background-mobile-secondary = c.base00;

        deprecated-card-bg = background-secondary;

        chat-background = c.base01;
        chat-border = c.base02;
        chat-input-container-background = c.base00;

        background-modifier-hover = c.base03 + "44";
        background-modifier-active = c.base02;
        background-modifier-selected = c.base02 + "cc";
        background-modifier-accent = c.base01;

        info-positive-background = c.base00;
        info-positive-foreground = text-positive;
        info-positive-text = text-normal;

        info-warning-background = c.base00;
        info-warning-foreground = text-warning;
        info-warning-text = text-normal;

        info-danger-background = c.base00;
        info-danger-foreground = text-danger;
        info-danger-text = text-normal;

        info-help-background = c.base00;
        info-help-foreground = c.base0F;
        info-help-text = text-normal;

        status-positive-background = button-positive-background;
        status-positive-text = c.base02;

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

        button-secondary-background = c.base02 + "bb";
        button-secondary-background-hover = c.base02 + "dd";
        button-secondary-background-active = c.base02;
        button-secondary-background-disabled = c.base02 + "99";

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

        scrollbar-thin-thumb = c.base01;

        scrollbar-auto-thumb = c.base00;
        scrollbar-auto-track = c.base00 + "88";
        scrollbar-auto-scrollbar-color-thumb = c.base00;
        scrollbar-auto-scrollbar-color-track = c.base00 + "88";

        input-background = c.base00;
        input-placeholder-text = c.base03;

        channels-default = c.base04;
        channel-icon = c.base04 + "99";

        channel-text-area-placeholder = input-placeholder-text;
        channeltextarea-background = input-background;

        activity-card-background = background-secondary;
        
        textbox-markdown-syntax = c.base03;

        spoiler-hidden-background = c.base00;
        spoiler-revealed-background = c.base02;

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
        search-popout-option-filter-text = c.base04;
        search-popout-option-non-text-color = c.base03;
        search-popout-option-filter-color = c.base03;
        search-popout-option-answer-color = c.base03;

        search-popout-date-picker-border = "1px solid ${c.base00}cc";
        search-popout-date-picker-hint-text = c.base04;
        search-popout-date-picker-hint-value-text = c.base01;
        search-popout-date-picker-hint-value-background = text-brand;
        search-popout-date-picker-hint-value-background-hover = text-brand + "cc";
    };

    css = let
        inherit (lib)
            map
            concatMapStrings
            concatMapStringsSep
            listToAttrs
            nameValuePair
            ;

        sel = tag: prefix:
            ":is(${tag}[class^='${prefix}-'], ${tag}[class*=' ${prefix}-'])";

        sel' = tag: prefixes: concatMapStrings (sel tag) prefixes;

        sels = tag: prefixes: ":is(${concatMapStringsSep ", " (sel tag) prefixes})";

        color = name: "color: ${name} !important;";
        bg = name: "background-color: ${name} !important;";

        addOpacity = fn: name: opacity: fn "${name}${opacity}";
        color' = addOpacity color;
        bg' = addOpacity bg;

        span = "span";
        div = "div";
        nav = "nav";
        section = "section";
        input = "input";
        button = "button";

        c = formatted;
    in ''
        :root {
            font-size: 93.75% !important;
        }

        :root, .theme-dark {
            ${colors.genVarDecls defs}
        }

        ${sel div "name"} { font-size: 15px !important; }

        code, ${sel span "inlineCode"}, ${sel div "codeLine"} {
            font-family: ${defs.font-code} !important;
            font-size: 14px !important;
        }

        ${sel div "divider"} {
            border-top-color: ${c.base02} !important;
        }

        ${sel div "checked"} { ${bg' c.base0B "88"} }

        ${sel nav "guilds"} {
            border-right: 1px solid ${c.base01} !important;
        }

        ${sel nav "guilds"} > ul { ${bg (byVariant' "white" "black")} }

        ${sel nav "guilds"} ${sel div "scrollerBase"} {
            background-color: ${c.base00}aa !important;
        }

        ${sels div [ "autocomplete" "categoryHeader" ]} { ${bg c.base00} }

        ${sel div "rail"} > ${sel div "list"} {
            ${bg' c.base01 "55"}
            border-right: 1px solid ${c.base01};
        }

        ${sel section "background"},
        ${sels div ["background" "fieldList"]} { ${bg c.base01} }

        ${sel div "homeContainer"} { ${bg' c.base00 "aa"} }

        ${sel div "userPanelInner"} > ${sel div "scrollerBase"} {
            backdrop-filter: brightness(${byVariant' "1.4" "0.55"});
        }

        ${sel div "usageWrapper"} > ${sel div "option"} { ${bg c.base01} }

        ${sel span "spoilerText"}:not(${sel span "hidden"}) { ${bg' c.base02 "77"} }

        ${sel' span ["spoilerText" "hidden"]} { opacity: 80% }

        ${sel div "chat"}, ${sel section "title"} {
            box-shadow: inset 1px 0 ${c.base00}44,
                        inset 1px 0 "white";
        }

        ${sel' "*" ["colorBrand" "lookFilled"]} { ${color c.base01} }

        ${sel div "textBadge"} { ${bg c.base03} }
        ${sel div "akaBadge"} { ${color c.base00} ${bg c.base04} }

        ${sel div "authedApp"} { ${bg c.base00} }

        ${sel "*" "emptyStateHeader"} { ${color c.base05} }
        ${sel "*" "emptyStateSubtext"} { ${color c.base06} }

        ${sels div ["payment" "paymentPane" "summaryInfo" "paginator"]} {
            ${bg c.base00} ${color c.base05}
        }

        ${sels div ["paymentRow" "bottomDivider"]} {
            border-bottom-color: ${c.base01} !important;
        }

        ${sels div ["pageActions" "pageButtonPrev" "pageButtonNext" "pageIndicator"]} {
            border-color: ${c.base02} !important;
        }

        ${sel div "codeRedemptionRedirect"} {
            ${color c.base05} ${bg c.base00}
            border-color: ${c.base02} !important;
        }

        ${sel div "slider"} ${sel div "bar"} { ${bg c.base02} }
        ${sel div "markDash"} { ${bg c.base02} }

        ${sel' div ["bar" "mention"]} { ${bg c.base09} }

        ${sel div "micTest"} ${sel div "progress"} { ${bg c.base01} }

        ${sel div "gameName"}, ${sel input "gameNameInput"} { ${color c.base05} }

        ${sel input "gameNameInput"}:focus,
        ${sel input "gameNameInput"}:hover { ${bg c.base00} }

        ${sel' div ["card" "game"]} {
            box-shadow: 0 1px 0 0 ${c.base02} !important;
        }

        ${sel div "nowPlayingAdd"} { ${color c.base04} }

        ${sel div "queryContainer"} {
            ${color c.base04} ${bg c.base00}
            border-bottom: 1px solid ${c.base02} !important;
        }

        ${sel div "queryContainer"} strong { ${color c.base05} }

        ${sel span "key"} {
            ${color c.base00}
            ${bg (byVariant' c.base03 c.base04)}
            box-shadow: inset 0 -4px 0 ${(byVariant' c.base04 c.base03)} !important;
        }

        ${sel "*" "colorPrimary"} { ${color c.base05} }
        ${sel button "lookLink"} { ${color c.base04} }

        ${sel' button ["fieldButton" "lookFilled"]} { ${bg c.base04} ${color c.base00} }

        ${sel div "folder"} { ${bg c.base01} }
        ${sel span "expandedFolderBackground"} { ${bg c.base01} }

        ${sel div "feedItemHeader"} {
            border-bottom: 1px solid ${c.base02}44 !important;
        }

        ${sel div "headerBarInner"}::after {
            background: transparent !important;
        }

        ${sel div "emojiAliasPlaceholderContent"} { ${color c.base05} }

        ${sel div "directoryModal"} { ${bg c.base01} }

        ${sel div "userPopoutOuter"} { backdrop-filter: blur(8px); }
        ${sel div "menu"} { ${bg c.base00} }
    '';
in {
    home.packages = [ pkgs.lexend ];

    programs.discocss = {
        enable = false;
        discordPackage = pkgs.discord-custom;

        inherit css;
    };

    xdg.configFile."discord/settings.json".text = ''
        {
            "SKIP_HOST_UPDATE": true,
            "DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOURE_DOING": true
        }
    '';
}