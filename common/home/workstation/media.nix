{ pkgs, flakes, ... }:

{
	home.file.keydb = {
		source = flakes.keydb;
		target = ".config/aacs/KEYDB.cfg";
	};
}
