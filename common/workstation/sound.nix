{ pkgs, ... }:

{
    # MIDI support
    boot.kernelModules = [ "snd-seq" "snd-rawmidi" ];

    # Manage audio server stuff
    environment.systemPackages = let p = pkgs; in [
        p.pavucontrol
        p.helvum
    ];

    # Allow audio access (I have no idea if this does anything)
    users.users.anna.extraGroups = [ "audio" "jackaudio" ];

    # Build packages with PulseAudio support...
    nixpkgs.config.pulseaudio = true;

    # ...but disable PulseAudio...
    hardware.pulseaudio.enable = false;

    # ...and use PipeWire instead!
    services.pipewire = {
        enable = true;

        # All the compatibility layers
        pulse.enable = true;
        jack.enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
    };

    # Allow pipewire to run with realtime priority to reduce audio latency
    security = {
        pam.loginLimits = [
            { domain = "@audio"; type = "-"; item = "nice"; value = "-20"; }
            { domain = "@audio"; type = "-"; item = "rtprio"; value = "99"; }
        ];

        rtkit.enable = true;
    };
}