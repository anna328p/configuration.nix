{ pkgs, ... }:

let
	passwdHash = "$6$o3HFaJySc0ptEcz$tr5ndkC9HMA0RDVobaLUncgzEiveeWtSJV8"
	              + "659EYdA2EnrNxB9vTrSmJVv5lAlF8nR0fu4HpBJ5e5wP02LHqq0";
in {
	users = {
		mutableUsers = false;
		defaultUserShell = pkgs.zsh;

		users.anna = {
			description = "Anna";
			isNormalUser = true;

			# consistent uid everywhere
			uid = 1000;

			# container support
			subUidRanges = [ { startUid = 100000; count = 9999; } ];
			subGidRanges = [ { startGid = 10000; count = 999; } ];

			# sudo rights
			extraGroups = [ "wheel" ];

			initialHashedPassword = passwdHash;
		};

		users.root.initialHashedPassword = passwdHash;
	};

	# https://xkcd.com/1200
	security.sudo.wheelNeedsPassword = false;
}
