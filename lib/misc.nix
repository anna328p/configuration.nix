{ lib, ... }:

with lib; rec {
	exports = self: { inherit (self)
		fontCss;
	};

	# FontOpt : { name : Str; size : Num }
	# fontCss : FontOpt -> Str
	fontCss = opt: let
		sizeStr = toString opt.size;
	in "${sizeStr}pt ${opt.name}";
}
