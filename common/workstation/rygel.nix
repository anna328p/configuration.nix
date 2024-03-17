{ lib, ... }:

{
    environment.etc."rygel.conf".source = let
        text = lib.generators.toINI {} {
            general = {
                ipv6 = true;
                enable-transcoding = true;
                media-engine = "librygel-media-engine-gst.so";
                interface = "";
                port = 0;
                log-level = "*:4";
                allow-upload = false;
                allow-deletion = false;
                acl-fallback-policy = true;
                strict-dlna = false;
            };

            # Plugins

            GstMediaEngine = {
                transcoders = "mp3;lpcm;mp2ts;wmv;aac;avc";
            };

            Renderer = {
                image-timeout = 15;
            };

            Tracker3 = {
                enabled = true;
                only-export-from = "@MUSIC@;@VIDEOS@;@PICTURES@";
                share-pictures = true;
                share-videos = true;
                share-music = true;
                strict-sharing = false;
                title = "@REALNAME@'s media on @PRETTY_HOSTNAME@";
            };

            MediaExport = { 
                enabled = true;
                title = "@REALNAME@'s media on @PRETTY_HOSTNAME@";
                uris = "@MUSIC@;@VIDEOS@;@PICTURES@";
                extract-metadata = false;
                monitor-changes = true;
                monitor-grace-timeout = 5;
                virtual-folders = true;
            };

            Playbin = {
                enabled = true;
                title = "Audio/Video playback on @PRETTY_HOSTNAME@";
            };

            Tracker.enabled = false;
            LMS.enabled = false;
            GstLaunch.enabled = false;
            Test.enabled = false;
            ExampleServerPluginVala.enabled = false;
            ExampleServerPluginC.enabled = false;
            ExampleRendererPluginVala.enabled = false;
            ExampleRendererPluginC.enabled = false;
            MPRIS.enabled = false;
            External.enabled = false;
            Ruih.enabled = false;
        };

        file = builtins.toFile "rygel.conf" text;
    in
        lib.mkForce file;
}