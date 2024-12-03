{ ... }:

{
    exports = { };

    base = root: locations: {
        inherit root locations;
        forceSSL = true;
        enableACME = true;
        http2 = true;
    };

    redirect = dest: {
        enableACME = true;
        addSSL = true;
        globalRedirect = dest;
    };
}