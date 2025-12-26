{ bundlerEnv
, ruby_latest
, ...
}:

bundlerEnv {
    name = "neovim-ruby-pkgs";
    ruby = ruby_latest;
    gemdir = ./.;
}