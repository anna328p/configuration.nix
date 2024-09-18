{ flakes, specialArgs, ... }:

flakes.nixos-generators.nixosGenerate {
    system = "x86_64-linux";

    modules = [
        ../../systems/iso
    ];

    inherit specialArgs;

    format = "install-iso";
}