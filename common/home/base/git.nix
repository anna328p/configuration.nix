{ ... }:

{
	programs.git = {
		enable = true;
		
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
