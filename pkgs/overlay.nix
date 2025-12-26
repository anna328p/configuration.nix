{ flakes, mkFlakeVer, ... }:

final: prev:

import ./all-packages.nix {
    inherit flakes mkFlakeVer;
    pkgs = final;
}