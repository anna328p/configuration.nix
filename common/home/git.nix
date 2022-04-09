{ pkgs, ... }:

{
	programs.git = {
		enable = true;
		package = pkgs.gitAndTools.gitFull;
		
		userName = "Anna Kudriavtsev";
		userEmail = "anna328p@gmail.com";

		ignores = [ "tags" ];

		includes = [
			{ contents = {
					pull.ff = "only";
					init.defaultBranch = "main";
			}; }
		];
	};
}

# vim: set ts=4 sw=4 noet :
