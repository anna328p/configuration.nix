{ ... }:

{
    misc.bookmarks = {
        enable = true;

        home = [
            "Documents/Docs"
            "work"
        ];

        global = [
            {
                name = "/ on theseus";
                target = "sftp://theseus.zerotier.ap5.network/";
            }
            {
                name = "/home/anna on theseus";
                target = "sftp://theseus.zerotier.ap5.network/home/anna";
            }
        ];
    };
}