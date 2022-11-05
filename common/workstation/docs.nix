{ pkgs, ... }:

{
	# Enable documentation globally

	environment.systemPackages = with pkgs; [
		man-pages man-pages-posix stdman linux-manual
	];

	documentation = {
		dev.enable = true;
	};
}
