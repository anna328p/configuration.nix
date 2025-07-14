{ pkgs, config, local-lib, ... }:

let
    inherit (local-lib) colors;

    scheme = config.colorScheme;
    formatted = colors.prefixHash scheme.palette;
    c = formatted;

    rootDefs = {
        # Popup panels
        arrowpanel-background = c.base01;
        arrowpanel-border-color = c.base02;
        arrowpanel-color = c.base05;
        arrowpanel-dimmed = c.base00;

        # window and toolbar background
        lwt-accent-color = c.base02;
        lwt-accent-color-inactive = c.base01;
        toolbar-bgcolor = c.base01;  

        # tabs with system theme - text is not controlled by variable
        tab-selected-bgcolor = c.base01;

        # tabs with any other theme
        lwt-text-color = c.base05;
        lwt-selected-tab-background-color = c.base01;

        # toolbar area
        toolbarbutton-icon-fill = c.base05;
        lwt-toolbarbutton-hover-background = c.base02;
        lwt-toolbarbutton-active-background = c.base03;

        # urlbar
        toolbar-field-border-color = c.base03;
        toolbar-field-focus-border-color = c.base04;
        urlbar-popup-url-color = c.base05;

        # urlbar Firefox < 92
        lwt-toolbar-field-background-color = c.base02;
        lwt-toolbar-field-focus = c.base02;
        lwt-toolbar-field-color = c.base05;
        lwt-toolbar-field-focus-color = c.base05;

        # urlbar Firefox 92+
        toolbar-field-background-color = c.base02;
        toolbar-field-focus-background-color = c.base02;
        toolbar-field-color = c.base05;
        toolbar-field-focus-color = c.base05;

        # sidebar - note the sidebar-box rule for the header-area
        lwt-sidebar-background-color = c.base01;
        lwt-sidebar-text-color = c.base05;

        autocomplete-popup-highlight-background = c.base04;
        autocomplete-popup-highlight-color = c.base01;
    };

    userChrome = ''
        /* github.com/MrOtherGuy/firefox-csshacks Mozilla Public License v. 2.0 */

        :root {
            ${colors.genVarDecls rootDefs}
        }

        /* line between nav-bar and tabs toolbar,
            also fallback color for border around selected tab */
        #navigator-toolbox { --lwt-tabs-border-color: ${c.base03} !important; }

        /* Line above tabs */
        #tabbrowser-tabs { --lwt-tab-line-color: ${c.base02} !important; }

        /* the header-area of sidebar needs this to work */
        #sidebar-box { --sidebar-background-color: ${c.base01} !important; }

        ::selection, ::-moz-selection, p::selection, p::-moz-selection {
            color: ${c.base01} !important;
            background-color: ${c.base04} !important;
        }
    '';

    # Sidebery
    sbDefs = {
        bg = c.base00;
        bg-img = "none";

        title-fg = c.base05;
        sub-title-fg = c.base05;
        label-fg = c.base05;
        label-fg-hover = c.base06;
        label-fg-click = c.base04;
        info-fg = c.base05;
        true-fg = c.base0B;
        false-fg = c.base09;
        active-fg = c.base05;
        inactive-fg = c.base04;
        favicons-placeholder-bg = c.base03;

        btn-bg = c.base02;
        btn-bg-hover = c.base01;
        btn-bg-active = c.base03;
        btn-fg = c.base05;
        btn-fg-hover = c.base04;
        btn-fg-active = c.base06;

        scroll-progress-bg = c.base0E;

        tabs-font = let F = config.misc.fonts.ui;
            in "${builtins.toString F.size}pt ${F.name}";

        tabs-height = "22px";
        tabs-fg = c.base04;
        tabs-fg-hover = c.base05;
        tabs-fg-active = c.base05;
        tabs-bg-hover = c.base01;
        tabs-bg-active = c.base03;
        tabs-activated-bg = c.base02;
        tabs-activated-fg = c.base05;
        tabs-selected-bg = c.base04;
        tabs-selected-fg = c.base01;
        tabs-lvl-indicator-bg = c.base03;
    };

    userContent = ''
        /* Sidebery color theme */
        /* Kind of a hack, should ideally be more specific */
        @-moz-document regexp("^moz-extension://.*/sidebar/index\.html$") {
            #root {
                ${colors.genVarDecls sbDefs}
            }
        }

        ::selection, ::-moz-selection, p::selection, p::-moz-selection {
            color: ${c.base01};
            background-color: ${c.base04};
        }
    '';
in {
    programs.firefox = {
        enable = true;
        package = pkgs.firefox-devedition;

        profiles.dev-edition-default = {
            name = "dev-edition-default";
            path = "dev-edition-default";
            id = 0; 

            inherit userChrome userContent;

            settings = {
                "general.smoothScroll" = false;
                "devtools.chrome.enabled" = true;
                "devtools.debugger.remote-enabled" = true;
                "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            };
        };
    };
}