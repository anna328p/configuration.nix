{ config, lib, flakes, ... }:

{
    imports = [
        flakes.nixos-hardware.nixosModules.common-cpu-amd-pstate
    ];

    boot = {
        kernelModules = [ "kvm-amd" ];
        kernelParams = [ "amd_pstate=active" ];  
    };

    nixpkgs.hostPlatform = lib.systems.examples.gnu64;
}