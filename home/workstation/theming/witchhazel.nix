{ lib, ... }:

{
    colorScheme = {
        slug = "witchhazel-hypercolor";
        name = "Witch Hazel Hypercolor";
        author = "Thea Flowers (https://thea.codes)";
        variant = "dark";

        palette = let
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
            c = dehashed;
        in {
            base00 = c.purps;
            base01 = c.shadow;
            base02 = c.midtone;
            base03 = c.fadedlilac;
            base04 = c.lilac;
            base05 = c.linen;
            base06 = c.lightgrey;
            base07 = c.amethyst';

            base08 = c.pink;
            base09 = c.brick;
            base0A = c.other;
            base0B = c.mint;
            base0C = c.turquoise;
            base0D = c.darklilac;
            base0E = c.clay';
            base0F = c.lilac;
        };
    };
}