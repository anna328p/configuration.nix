{ lib, ... }:

{
    colorScheme = {
        slug = "witchhazel-hypercolor";
        name = "Witch Hazel Hypercolor";
        author = "Thea Flowers (https://thea.codes)";
        kind = "dark";

        colors = let
            sourceColors = {
                rouge      = "#960050";
                clay       = "#894E63";
                clay'      = "#b36581";
                brick      = "#DC7070";
                pink       = "#FFB8D1";
                sunflower  = "#FFF352";
                mint       = "#C2FFDF";
                turquoise  = "#81EEFF";

                lightgrey  = "#BFBFBF";
                linen      = "#F8F8F2";

                midnight   = "#1e0010";
                amethyst   = "#131218";
                purps      = "#282634";
                shadow     = "#3B364E";
                midtone    = "#554e73";
                amethyst'  = "#716799";
                fadedlilac = "#8077a8";
                lilac      = "#DCC8FF";
                darklilac  = "#C5A3FF";
                other      = "#ffdc97";
            };

            dehashed = lib.mapAttrs (_: lib.removePrefix "#") sourceColors;
        in with dehashed; {
            base00 = purps;
            base01 = shadow;
            base02 = midtone;
            base03 = fadedlilac;
            base04 = lilac;
            base05 = linen;
            base06 = lightgrey;
            base07 = amethyst';

            base08 = pink;
            base09 = brick;
            base0A = other;
            base0B = mint;
            base0C = turquoise;
            base0D = darklilac;
            base0E = clay';
            base0F = lilac;
        };
    };
}
