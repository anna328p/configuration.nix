{ lib, ... }:

{
	programs.ssh = {
		enable = true;
		compression = true;
		controlMaster = "auto";
		controlPersist = "30m";
		forwardAgent = true;

		matchBlocks = let
		  servers = [ "leonardo" "neo" "iris" "talos" "jason" "heracles" "castor" "pollux" "cyamites" "WebServer" ];
		  serverBlock = name: { "${name}" = { user = "anna"; hostname = "${name}.dk0.us"; }; };
		  serverBlocks = lib.foldr (a: b: a // b) {} (builtins.map serverBlock servers);

		in serverBlocks // {
			"theseus" = {
				user = "anna";
				hostname = "10.255.1.5";
				port = 22;
			};

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
				identityFile = "/home/anna/.ssh/id_ghd";
			};
		};
	};
}

# vim: set ts=4 sw=4 noet :
