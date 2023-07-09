{ ... }:

{
    programs.git = {
        enable = true;
        
        ignores = [ "tags" ];

        includes = [
            { contents = {
                    pull.ff = "only";
                    init.defaultBranch = "main";
            }; }
        ];
    };
}