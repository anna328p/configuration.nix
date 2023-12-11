{ local-lib, ... }:

let
    inherit (local-lib) unrollArgSequence __;
    inherit (builtins) isList;
in {
    xdg.mimeApps.enable = true;

    xdg.mimeApps.defaultApplications = unrollArgSequence isList
        "text/plain" "text/markdown"
        "application/xml" "application/xml-dtd"
        "application/json" "application/x-yaml"
        "application/x-ruby"
            [ "nvim.desktop" ]

        "application/vnd.oasis.opendocument.text"
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            [ "writer.desktop" ] # LibreOffice Writer

        "application/pdf"
            [ "org.gnome.Evince.desktop" ]

        "image/jpeg" "image/png" "image/jxl"
        "image/webp" "image/heic" "image/avif"
        "image/svg+xml"
            [ "org.gnome.eog.desktop" ]

        "x-scheme-handler/sms" "x-scheme-handler/tel"
            [ "org.gnome.Shell.Extensions.GSConnect.desktop" ]

        "audio/aac" "audio/mpeg"
        "audio/wav" "audio/x-wav" "audio/flac"
        "audio/ogg" "audio/x-vorbis+ogg" "audio/opus" "audio/x-opus+ogg"
        "audio/x-matroska"
            [ "mpv.desktop" ]

        "x-scheme-handler/magnet"
            [ "transgui.desktop" ]
        __ ;
}