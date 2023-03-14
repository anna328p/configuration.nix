{ lib, config, ... }:

{
	programs.ssh = {
		enable = true;
		compression = true;
		controlMaster = "auto";
		controlPersist = "30m";
		forwardAgent = true;

		matchBlocks = with lib; let
			mkServerBlocks = domain:
				(flip genAttrs) (name: {
					user = config.home.username;
					hostname = "${name}.${domain}";
				});

			serverNames = [
				"leonardo" "neo" "iris" "heracles" "cyamites"
				"theseus"
			];

		in (mkServerBlocks "dk0.us" serverNames) // {
			"github" = {
				user = "git";
				hostname = "github.com";
			};

			"gitlab" = {
				user = "git";
				hostname = "gitlab.com";
				identityFile = "~/.ssh/id_rsa";
			};

			"ews" = {
				user = "anna10";
				hostname = "linux.ews.illinois.edu";
			};

			"uiweb" = {
				user = "anna10";
				hostname = "anna10.web.illinois.edu";
			};

			"ghd" = {
				user = "git";
				hostname = "github-dev.cs.illinois.edu";
				identityFile = "~/.ssh/id_ghd";
			};
		};
	};
}

# vim: set ts=4 sw=4 noet :
