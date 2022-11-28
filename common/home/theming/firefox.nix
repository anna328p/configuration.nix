{ pkgs, lib, config, ... }:

{
	programs.firefox.enable = true;
	programs.firefox.package = pkgs.firefox-devedition-bin;

	programs.firefox.profiles.dev-edition-default = {
		id = 0;	
		isDefault = true;

		userChrome = let
			formatted = lib.mapAttrs (_: v: "#${v}") config.colorScheme.colors;
		in with formatted; ''
			/* github.com/MrOtherGuy/firefox-csshacks Mozilla Public License v. 2.0 */

			:root {
			  /* Popup panels */
			  --arrowpanel-background: ${base01} !important;
			  --arrowpanel-border-color: ${base02} !important;
			  --arrowpanel-color: ${base05} !important;
			  --arrowpanel-dimmed: ${base00} !important;

			  /* window and toolbar background */
			  --lwt-accent-color: ${base01} !important;
			  --lwt-accent-color-inactive: ${base00} !important;
			  --toolbar-bgcolor: ${base00} !important;  

			  /* tabs with system theme - text is not controlled by variable */
			  --tab-selected-bgcolor: ${base00} !important;

			  /* tabs with any other theme */
			  --lwt-text-color: ${base05} !important;
			  --lwt-selected-tab-background-color: ${base00} !important;

			  /* toolbar area */
			  --toolbarbutton-icon-fill: ${base05} !important;
			  --lwt-toolbarbutton-hover-background: ${base01} !important;
			  --lwt-toolbarbutton-active-background: ${base02} !important;

			  /* urlbar */
			  --toolbar-field-border-color: ${base03} !important;
			  --toolbar-field-focus-border-color: ${base04} !important;
			  --urlbar-popup-url-color: ${base05} !important;

			  /* urlbar Firefox < 92 */
			  --lwt-toolbar-field-background-color: ${base01} !important;
			  --lwt-toolbar-field-focus: ${base01} !important;
			  --lwt-toolbar-field-color: ${base05} !important;
			  --lwt-toolbar-field-focus-color: ${base05} !important;

			  /* urlbar Firefox 92+ */
			  --toolbar-field-background-color: ${base01} !important;
			  --toolbar-field-focus-background-color: ${base01} !important;
			  --toolbar-field-color: ${base05} !important;
			  --toolbar-field-focus-color: ${base05} !important;

			  /* sidebar - note the sidebar-box rule for the header-area */
			  --lwt-sidebar-background-color: ${base00} !important;
			  --lwt-sidebar-text-color: ${base05} !important;
			}

			/* line between nav-bar and tabs toolbar,
				also fallback color for border around selected tab */
			#navigator-toolbox { --lwt-tabs-border-color: ${base02} !important; }

			/* Line above tabs */
			#tabbrowser-tabs { --lwt-tab-line-color: ${base01} !important; }

			/* the header-area of sidebar needs this to work */
			#sidebar-box { --sidebar-background-color: ${base00} !important; }
		'';
	};
}
