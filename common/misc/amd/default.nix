{ config, pkgs, lib, flakes, ... }:

{
    imports = [
        flakes.nixos-hardware.nixosModules.common-cpu-amd-pstate
        flakes.nixos-hardware.nixosModules.common-cpu-amd-zenpower
        ./rocm.nix
    ];

    boot = {
        kernelModules = [ "kvm-amd" ];
    };


    nixpkgs.hostPlatform = lib.systems.examples.gnu64;
}