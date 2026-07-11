{ ... }:

{
    users.users = {
        erin = {
            isNormalUser = true;
            description = "Erin";
            extraGroups = [ "networkmanager" ];
            initialHashedPassword = "$6$dOCIEzF15uus8kTQ$IPpdEo3HASrh7BNFzNB4NHKK1qrQBEOSnx32Y7drVE8NUg8dMf0dv2gIKo3n7lNTAdHsRFUwyzr5z2N.3dhbW1";
            uid = 1001;
        };

        trish = {
            isNormalUser = true;
            description = "trish";
            initialHashedPassword = "$6$qnabnC1KTN95W.jf$QwYdsYRsHDB0Wc22egnkiDWWq0bI2xVhy9xNQZh6Bu/xBmrIbszariC9L62ry2IZwZbSZQeEV5KJavBZ1tqIu0";
            uid = 1002;
        };
    };
}