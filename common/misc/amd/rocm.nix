{ pkgs, ... }:

let
    p = pkgs;
in {
    hardware.graphics.extraPackages = [
        p.rocmPackages.clr.icd
        p.clinfo
    ];

    environment.systemPackages = [
        p.rocmPackages.clr
        p.amdgpu_top
        p.clinfo
    ];
}