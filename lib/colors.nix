{ L, lib, ... }:

let
    inherit (L)
        o
        mapAttrValues
        addStrings
        oo
        concatLines
        mapSetEntries
        ;
    
    inherit (lib) 
        substring 
        stringLength
        toLower
        ;
    
    inherit (builtins)
        floor
        sqrt
        ;

    # Math helpers
    pow = base: exp:
        if exp == 0 then 1.0
        else if exp == 1 then base
        else if exp == 2 then base * base
        else if exp == 3 then base * base * base
        else if exp < 0 then 1.0 / (pow base (-exp))
        else base * (pow base (exp - 1));

    abs = x: if x < 0.0 then -x else x;

    min = a: b: if a < b then a else b;
    max = a: b: if a > b then a else b;
    
    clamp = x: minVal: maxVal: min (max x minVal) maxVal;

    # Atan2 approximation for hue calculation
    # Returns angle in radians [-pi, pi]
    atan2 = y: x:
        let
            pi = 3.14159265358979323846;
            
            # atan approximation using polynomial for |x| < 1
            atanApprox = x:
                let
                    x2 = x * x;
                    x3 = x2 * x;
                    x5 = x3 * x2;
                    x7 = x5 * x2;
                    x9 = x7 * x2;
                in
                x - x3 / 3.0 + x5 / 5.0 - x7 / 7.0 + x9 / 9.0;
        in
        if x == 0.0 && y == 0.0 then 0.0
        else if x > 0.0 then atanApprox (y / x)
        else if x < 0.0 && y >= 0.0 then atanApprox (y / x) + pi
        else if x < 0.0 && y < 0.0 then atanApprox (y / x) - pi
        else if y > 0.0 then pi / 2.0
        else -pi / 2.0;

    # Cosine approximation using Taylor series
    cos = x:
        let
            pi = 3.14159265358979323846;
            # Normalize to [0, 2*pi]
            normalized = x - floor (x / (2.0 * pi)) * (2.0 * pi);
            # Use Taylor series
            x2 = normalized * normalized;
            x4 = x2 * x2;
            x6 = x4 * x2;
            x8 = x6 * x2;
        in
        1.0 - x2 / 2.0 + x4 / 24.0 - x6 / 720.0 + x8 / 40320.0;

    # Sine approximation using cos
    sin = x: cos (x - 3.14159265358979323846 / 2.0);

    # Cbrt approximation using Newton's method
    cbrt = x:
        let
            sign = if x < 0.0 then -1.0 else 1.0;
            absX = abs x;
            
            # Initial guess using pow
            initial = if absX > 0.0 then pow absX (1.0 / 3.0) else 0.0;
            
            # Newton's method iterations
            improve = guess: 
                if guess == 0.0 then 0.0
                else (2.0 * guess + absX / (guess * guess)) / 3.0;
            
            iterate = guess: n:
                if n == 0 then guess
                else iterate (improve guess) (n - 1);
            
            result = if initial == 0.0 then 0.0 else iterate initial 5;
        in
        sign * result;

    # Hex color parsing
    hexToDec = hex:
        let
            chars = "0123456789abcdef";
            lower = toLower hex;
            
            charToNum = c:
                let
                    findIndex = str: char: idx:
                        if idx >= stringLength str then -1
                        else if substring idx 1 str == char then idx
                        else findIndex str char (idx + 1);
                in
                findIndex chars c 0;
                
            digit1 = charToNum (substring 0 1 lower);
            digit2 = charToNum (substring 1 1 lower);
        in
        digit1 * 16 + digit2;

    # Parse hex color string to RGB (0-1 range)
    hexToRgb = hex:
        let
            clean = if substring 0 1 hex == "#" 
                   then substring 1 (stringLength hex - 1) hex
                   else hex;
            
            r = hexToDec (substring 0 2 clean);
            g = hexToDec (substring 2 2 clean);
            b = hexToDec (substring 4 2 clean);
        in
        { r = r / 255.0; g = g / 255.0; b = b / 255.0; };

    # Convert RGB (0-1) to hex string
    rgbToHex = rgb:
        let
            toHexByte = val:
                let
                    clamped = clamp val 0.0 1.0;
                    byte = floor (clamped * 255.0 + 0.5);
                    chars = "0123456789abcdef";
                    high = substring (byte / 16) 1 chars;
                    low = substring (byte - (byte / 16) * 16) 1 chars;
                in
                high + low;
        in
        "#" + toHexByte rgb.r + toHexByte rgb.g + toHexByte rgb.b;

    # sRGB gamma correction
    srgbToLinear = c:
        if c <= 0.04045
        then c / 12.92
        else pow ((c + 0.055) / 1.055) 2.4;

    linearToSrgb = c:
        if c <= 0.0031308
        then c * 12.92
        else 1.055 * pow c (1.0 / 2.4) - 0.055;

    # RGB <-> Linear RGB
    rgbToLinear = rgb: {
        r = srgbToLinear rgb.r;
        g = srgbToLinear rgb.g;
        b = srgbToLinear rgb.b;
    };

    linearToRgb = linear: {
        r = linearToSrgb linear.r;
        g = linearToSrgb linear.g;
        b = linearToSrgb linear.b;
    };

    # Linear RGB -> Oklab
    # Based on https://bottosson.github.io/posts/oklab/
    linearRgbToOklab = rgb:
        let
            l = 0.4122214708 * rgb.r + 0.5363325363 * rgb.g + 0.0514459929 * rgb.b;
            m = 0.2119034982 * rgb.r + 0.6806995451 * rgb.g + 0.1073969566 * rgb.b;
            s = 0.0883024619 * rgb.r + 0.2817188376 * rgb.g + 0.6299787005 * rgb.b;

            l_ = cbrt l;
            m_ = cbrt m;
            s_ = cbrt s;
        in
        {
            L = 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_;
            a = 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_;
            b = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_;
        };

    # Oklab -> Linear RGB
    oklabToLinearRgb = lab:
        let
            l_ = lab.L + 0.3963377774 * lab.a + 0.2158037573 * lab.b;
            m_ = lab.L - 0.1055613458 * lab.a - 0.0638541728 * lab.b;
            s_ = lab.L - 0.0894841775 * lab.a - 1.2914855480 * lab.b;

            l = l_ * l_ * l_;
            m = m_ * m_ * m_;
            s = s_ * s_ * s_;
        in
        {
            r = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s;
            g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s;
            b = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s;
        };

    # Oklab -> OkHSV
    # Based on https://bottosson.github.io/posts/colorpicker/
    oklabToOkhsv = lab:
        let
            pi = 3.14159265358979323846;
            L = lab.L;
            a = lab.a;
            b = lab.b;
            
            c = sqrt (a * a + b * b);
            
            # Calculate hue
            h = if c < 0.0001 then 0.0
                else
                    let
                        angle = atan2 b a;
                        normalized = angle / (2.0 * pi);
                    in
                    if normalized < 0.0 then normalized + 1.0 else normalized;
            
            # For saturation and value, we use a simplified approach
            # Full implementation would require gamut mapping
            s = if L < 0.0001 then 0.0 else clamp (c / L) 0.0 1.0;
            v = L;
        in
        { h = h; s = s; v = clamp v 0.0 1.0; };

    # OkHSV -> Oklab
    okhsvToOklab = hsv:
        let
            pi = 3.14159265358979323846;
            h = hsv.h;
            s = hsv.s;
            v = hsv.v;
            
            L = v;
            c = L * s;
            
            angle = h * 2.0 * pi;
            a = c * cos angle;
            b = c * sin angle;
        in
        { L = L; a = a; b = b; };

    # Oklab -> OkHSL
    # Based on https://bottosson.github.io/posts/colorpicker/
    oklabToOkhsl = lab:
        let
            pi = 3.14159265358979323846;
            L = lab.L;
            a = lab.a;
            b = lab.b;
            
            c = sqrt (a * a + b * b);
            
            # Calculate hue (same as HSV)
            h = if c < 0.0001 then 0.0
                else
                    let
                        angle = atan2 b a;
                        normalized = angle / (2.0 * pi);
                    in
                    if normalized < 0.0 then normalized + 1.0 else normalized;
            
            # Lightness in HSL
            l = L;
            
            # Saturation calculation for HSL
            s = if l < 0.0001 || l > 0.9999 then 0.0
                else clamp (c / (min l (1.0 - l))) 0.0 1.0;
        in
        { h = h; s = s; l = clamp l 0.0 1.0; };

    # OkHSL -> Oklab
    okhslToOklab = hsl:
        let
            pi = 3.14159265358979323846;
            h = hsl.h;
            s = hsl.s;
            l = hsl.l;
            
            c = s * (min l (1.0 - l));
            
            angle = h * 2.0 * pi;
            a = c * cos angle;
            b = c * sin angle;
        in
        { L = l; a = a; b = b; };

    # High-level conversion functions
    hexToOklab = hex: linearRgbToOklab (rgbToLinear (hexToRgb hex));
    oklabToHex = lab: rgbToHex (linearToRgb (oklabToLinearRgb lab));
    
    hexToOkhsv = hex: oklabToOkhsv (hexToOklab hex);
    okhsvToHex = hsv: oklabToHex (okhsvToOklab hsv);
    
    hexToOkhsl = hex: oklabToOkhsl (hexToOklab hex);
    okhslToHex = hsl: oklabToHex (okhslToOklab hsl);

in rec {
    exports = self: { inherit (self)
        prefixHash genDecls genVarDecls byVariant
        hexToRgb rgbToHex
        hexToOklab oklabToHex
        hexToOkhsv okhsvToHex
        hexToOkhsl okhslToHex
        rgbToLinear linearToRgb
        linearRgbToOklab oklabToLinearRgb
        oklabToOkhsv okhsvToOklab
        oklabToOkhsl okhslToOklab;
    };

    prefixAttrs = o mapAttrValues addStrings;
    prefixHash = prefixAttrs "#";

    genDecls = oo concatLines mapSetEntries;

    genVarDecls = genDecls (k: v: "--${k}: ${v} !important;");

    byVariant = variant: light: dark: { inherit light dark; }.${variant};

    # Export all new functions
    inherit
        hexToRgb rgbToHex
        hexToOklab oklabToHex
        hexToOkhsv okhsvToHex
        hexToOkhsl okhslToHex
        rgbToLinear linearToRgb
        linearRgbToOklab oklabToLinearRgb
        oklabToOkhsv okhsvToOklab
        oklabToOkhsl okhslToOklab
        ;
}