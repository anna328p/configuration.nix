{ pkgs, lib, config, L, ... }:

let
	scheme = config.colorScheme;
	formatted = L.colors.prefixHash scheme.colors;

	rootDefs = with formatted; {
		# Popup panels
		arrowpanel-background = base01;
		arrowpanel-border-color = base02;
		arrowpanel-color = base05;
		arrowpanel-dimmed = base00;

		# window and toolbar background
		lwt-accent-color = base02;
		lwt-accent-color-inactive = base01;
		toolbar-bgcolor = base01;  

		# tabs with system theme - text is not controlled by variable
		tab-selected-bgcolor = base01;

		# tabs with any other theme
		lwt-text-color = base05;
		lwt-selected-tab-background-color = base01;

		# toolbar area
		toolbarbutton-icon-fill = base05;
		lwt-toolbarbutton-hover-background = base02;
		lwt-toolbarbutton-active-background = base03;

		# urlbar
		toolbar-field-border-color = base03;
		toolbar-field-focus-border-color = base04;
		urlbar-popup-url-color = base05;

		# urlbar Firefox < 92
		lwt-toolbar-field-background-color = base02;
		lwt-toolbar-field-focus = base02;
		lwt-toolbar-field-color = base05;
		lwt-toolbar-field-focus-color = base05;

		# urlbar Firefox 92+
		toolbar-field-background-color = base02;
		toolbar-field-focus-background-color = base02;
		toolbar-field-color = base05;
		toolbar-field-focus-color = base05;

		# sidebar - note the sidebar-box rule for the header-area
		lwt-sidebar-background-color = base01;
		lwt-sidebar-text-color = base05;

		autocomplete-popup-highlight-background = base04;
		autocomplete-popup-highlight-color = base01;
	};

	userChrome = with formatted; ''
		/* github.com/MrOtherGuy/firefox-csshacks Mozilla Public License v. 2.0 */

		:root {
			${L.colors.genVarDecls rootDefs}
		}

		/* line between nav-bar and tabs toolbar,
			also fallback color for border around selected tab */
		#navigator-toolbox { --lwt-tabs-border-color: ${base03} !important; }

		/* Line above tabs */
		#tabbrowser-tabs { --lwt-tab-line-color: ${base02} !important; }

		/* the header-area of sidebar needs this to work */
		#sidebar-box { --sidebar-background-color: ${base01} !important; }

		::selection, ::-moz-selection, p::selection, p::-moz-selection {
			color: ${base01} !important;
			background-color: ${base04} !important;
		}
	'';

	# Sidebery
	sbDefs = with formatted; {
		bg = base00;
		bg-img = "none";

		title-fg = base05;
		sub-title-fg = base05;
		label-fg = base05;
		label-fg-hover = base06;
		label-fg-click = base04;
		info-fg = base05;
		true-fg = base0B;
		false-fg = base09;
		active-fg = base05;
		inactive-fg = base04;
		favicons-placeholder-bg = base03;

		btn-bg = base02;
		btn-bg-hover = base01;
		btn-bg-active = base03;
		btn-fg = base05;
		btn-fg-hover = base04;
		btn-fg-active = base06;

		scroll-progress-bg = base0E;

		tabs-height = "22px";
		tabs-font = "${builtins.toString config.gtk.font.size}pt " + 
						"\"${config.gtk.font.name}\"";
		tabs-fg = base04;
		tabs-fg-hover = base05;
		tabs-fg-active = base05;
		tabs-bg-hover = base01;
		tabs-bg-active = base03;
		tabs-activated-bg = base02;
		tabs-activated-fg = base05;
		tabs-selected-bg = base04;
		tabs-selected-fg = base01;
		tabs-lvl-indicator-bg = base03;
	};

	userContent = with formatted; ''
		/* Sidebery color theme */
		/* Kind of a hack, should ideally be more specific */
		@-moz-document regexp("^moz-extension://.*/sidebar/index\.html$") {
			#root {
				${L.colors.genVarDecls sbDefs}
			}
		}
	'';
in {
	programs.firefox = {
		enable = true;
		package = pkgs.firefox-devedition-bin;

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
