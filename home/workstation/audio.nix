{ lib, ... }:

{
    services.easyeffects.enable = true;

    # constantly idles and destroys battery life...
    services.fluidsynth.enable = lib.mkForce false;
}