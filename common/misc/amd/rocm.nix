{ pkgs, ... }:

let
    p = pkgs;
in {
    hardware.graphics.extraPackages = [
        p.rocmPackages.clr.icd
    ];

    environment.systemPackages = [
        p.rocmPackages.clr
        p.amdgpu_top
        p.clinfo
    ];
}