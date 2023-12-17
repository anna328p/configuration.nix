{ bundlerEnv
, ruby_latest
, ...
}:

bundlerEnv {
    name = "neovim-ruby-env";

    ruby = ruby_latest;

    gemdir = ./.;
}