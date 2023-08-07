{ pkgs, lib, L, config, systemConfig, ... }:

{
    home.sessionVariables.VISUAL = "nvim";

    programs.neovim = {
        enable = true;
        withRuby = false;

        defaultEditor = true;

        extraPackages = with pkgs; [
            rubyPackages_latest.solargraph
            ccls

            nodePackages.vscode-langservers-extracted
            nodePackages.bash-language-server

            rubyPackages_latest.rubocop
            proselint
        ] ++ (lib.optionals systemConfig.misc.buildFull (with pkgs; [
            nil statix
            haskell-language-server
            rust-analyzer
            shellcheck
        ]));

        extraLuaConfig = let
            rg = lib.getExe pkgs.ripgrep;

            opts = {
                # integration
                mouse = "a";
                title = true;

                # searching
                ignorecase = true;
                smartcase = true;

                # view
                number = true;
                cursorline = true;
                scrolloff = 3;
                sidescrolloff = 5;

                # don't show mode twice
                showmode = false;

                # splits
                splitbelow = true;
                splitright = true;

                # indentation
                copyindent = true;
                tabstop = 4;
                shiftwidth = 4;
                expandtab = false;

                # misc
                undofile = true;
                completeopt = [ "menu" "menuone" "noselect" ];

                # ripgrep
                grepprg = "${rg} --vimgrep --hidden --glob '!.git'";
            };

            inherit (L.lua) __findFile;
        in with L.lua; with L; Code [
            (Paste (o mapSetPairs uncurry
                (k: v: (Set (Index <vim.opt> k) v)) opts))

            (CallOn <vim.opt.clipboard> "append" [ "unnamed" ])

            # typo protection

            (Call <vim.api.nvim_create_user_command>
                [ "Q" "quit" {} ])

            (Call <vim.api.nvim_create_user_command>
                [ "W" "write <args>" { nargs = "*"; } ])

            # diagnostics

            (Call <vim.diagnostic.config> {
                virtual_text = false; # Turn off inline diagnostics
                underline = true;
                signs = true;
                severity_sort = true;

                float = {
                    source = "if_many";
                    show_header = true;
                    focusable = false;
                    max_width = 80;
                };
            })

            # open diagnostic float on cursor hover
            (Set <vim.opt.updatetime> 300)
            (Call <vim.api.nvim_create_autocmd> [ "CursorHold" {
                callback = Function ({ }: [
                    (Call <vim.diagnostic.open_float> []) ]);
            }])
        ];

        plugins = with pkgs.vimPlugins; with L.lua; let
            luaPlugin = plugin: config: rest: {
                inherit plugin config;
                type = "lua";
            } // rest;

            prefixHashes = L.mapAttrValues (v: "#" + v);

            inherit (L.lua) __findFile;
        in [
            # visual
            (luaPlugin nvim-base16 (Code [
                (Set <vim.opt.termguicolors> true)
                (CallFrom (Require "base16-colorscheme") "setup"
                    (prefixHashes config.colorScheme.colors))
            ]) { })

            (luaPlugin nvim-colorizer-lua (Code [
                (CallFrom (Require "colorizer") "setup" {
                    user_default_options.mode = "virtualtext";
                })
            ]) { })

            (luaPlugin rainbow-delimiters-nvim (Code (let
                links = {
                    "RainbowDelimiterRed"    =  "rainbowcol1";
                    "RainbowDelimiterYellow" =  "rainbowcol2";
                    "RainbowDelimiterBlue"   =  "rainbowcol3";
                    "RainbowDelimiterOrange" =  "rainbowcol4";
                    "RainbowDelimiterGreen"  =  "rainbowcol5";
                    "RainbowDelimiterViolet" =  "rainbowcol6";
                    "RainbowDelimiterCyan"   =  "rainbowcol7";
                };

                mkHighlight = group: target:
                    (Call <vim.api.nvim_set_hl>
                        [ 0 group { link = target; } ]);

            in
                with L; o mapSetPairs uncurry mkHighlight links
            )) { })

            (luaPlugin gitsigns-nvim (Code [
                (CallFrom (Require "gitsigns") "setup" { })
            ]) { })

            (luaPlugin lualine-nvim (Code [
                (CallFrom (Require "lualine") "setup" {
                    options = {
                        icons_enabled = false;
                        theme = "base16";
                    };
                 })
            ]) { })

            (luaPlugin tabline-nvim (Code [
                (CallFrom (Require "tabline") "setup" {
                    options = {
                        show_devicons = false;
                        show_filename_only = true;
                    };
                 })
            ]) { })

            nvim-treesitter-endwise

            (luaPlugin nvim-treesitter.withAllGrammars (Code [
                (CallFrom (Require "nvim-treesitter.configs") "setup" {
                    highlight.enable = true;
                    indent.enable = true;
                    endwise.enable = true;
                })
            ]) {
                runtime."after/queries/nix/injections.scm".source =
                    ./nvim/nix-injections.scm;
            })

            playground

            (luaPlugin nvim-treesitter-context (Code [
                (CallFrom (Require "treesitter-context") "setup" {
                    enable = true;
                })
            ]) { })

            (luaPlugin indent-blankline-nvim (Code [
                # show indentation levels
                (CallFrom (Require "indent_blankline") "setup" {
                    use_treesitter = true;
                    show_trailing_blankline_indent = false;
                    show_current_context = true;
                })
            ]) { })

            (luaPlugin nvim-surround (Code [
                (CallFrom (Require "nvim-surround") "setup" { })
            ]) { })

            #vim-illuminate

            # language servers

            cmp-nvim-lsp

            (luaPlugin nvim-lspconfig (Code [
                (SetLocal <lspconfig> (Require "lspconfig"))

                (SetLocal <lsp_caps>
                    (Call <vim.lsp.protocol.make_client_capabilities> []))

                (SetLocal <cmp_caps>
                    (CallFrom (Require "cmp_nvim_lsp")
                        "default_capabilities" []))

                (SetLocal <file_watching_cap> {
                    workspace.didChangeWatchedFiles.dynamicRegistration = true;
                })

                (SetLocal <caps> (Call <vim.tbl_deep_extend> [
                    "force"
                    <lsp_caps>
                    <cmp_caps>
                    <file_watching_cap> ]))

                (SetLocal <auto_ls> [
                    "hls" "bashls" "cssls" "rust_analyzer" ])

                (ForEach (IPairs <auto_ls>) ({ _, name }: [
                    (CallFrom (Index <lspconfig> name) "setup" {
                        capabilities = <caps>;
                    }) ]))

                (Call <lspconfig.solargraph.setup> {
                    capabilities = <caps>;
                    cmd = [
                        "bash"
                        "-c"
                        ("bundle exec solargraph --version"
                            + " && exec bundle exec solargraph stdio"
                            + " || solargraph stdio")
                    ];
                })

                (Call <lspconfig.nil_ls.setup> {
                    capabilities = <caps>;

                    settings.nil = let
                        nixWrapped = pkgs.writeShellScript "nix-wrapped" ''
                            exec ${lib.getExe systemConfig.nix.package} \
                                --allow-import-from-derivation "$@"
                        '';
                    in {
                        diagnostics.ignored = [ "uri_literal" ];
                        nix = {
                            binary = "${nixWrapped}";
                            maxMemoryMB = 8192;

                            flake = {
                                autoArchive = true;
                                autoEvalInputs = true;
                            };
                        };
                    };
                })

                (Call <lspconfig.ccls.setup> {
                    capabilities = <caps>;
                    single_file_support = true;
                })

                (Call <vim.api.nvim_create_autocmd> [ "LspAttach" {
                    callback = Function ({ args }: [
                        (SetLocal <cid>
                            (Index' args [ "data" "client_id" ]))

                        (SetLocal <client>
                            (Call <vim.lsp.get_client_by_id> [ <cid> ]))

                        (If (Eq <client.name> "nil_ls") [
                            (Set (Index' <client> [
                                    "server_capabilities"
                                    "semanticTokensProvider" ])
                                null) ])]);
                } ])
            ]) { })

            (let
                statixConfig = pkgs.mkNamedTOML.generate "statix.toml" {
                    disabled = [ "unquoted_uri" "empty_pattern" ];
                };

            in luaPlugin null-ls-nvim (Code [
                (SetLocal <null_ls> (Require "null-ls"))

                (CallFrom <null_ls> "setup" {
                    sources = [
                        <null_ls.builtins.diagnostics.shellcheck>
                        <null_ls.builtins.code_actions.shellcheck>
                        <null_ls.builtins.code_actions.statix>

                        (CallFrom <null_ls.builtins.diagnostics.statix> "with" {
                            extra_args = [ "--config" "${statixConfig}" ];
                        })
                    ];
                 })
            ]) { })

            # completions
            luasnip cmp_luasnip cmp-nvim-lua
            cmp-omni
            cmp-treesitter
            cmp-buffer cmp-tmux
            cmp-emoji

            (luaPlugin nvim-cmp (Code [
                (SetLocal <cmp> (Require "cmp"))

                (CallFrom <cmp> "setup" [ {
                    snippet.expand = Function ({ args }: [
                        (CallFrom (Require "luasnip") "lsp_expand" [
                            (Index args "body")
                        ])]);

                    mapping = {
                        "<C-e>" = Call <cmp.mapping.close> [];

                        "<Tab>" = Call <cmp.mapping> [
                            (Function ({ fallback }: [
                                (If (Call <cmp.visible> []) {
                                    Then = [ (Call <cmp.select_next_item> []) ];
                                    Else = [ (Call fallback []) ];
                                })]))
                            [ "i" "s" ]
                        ];

                        "<S-Tab>" = Call <cmp.mapping> [
                            (Function ({ fallback }: [
                                (If (Call <cmp.visible> []) {
                                    Then = [ (Call <cmp.select_prev_item> []) ];
                                    Else = [ (Call fallback []) ];
                                })]))
                            [ "i" "s" ]
                        ];

                        "<C-Space>" = Call <cmp.mapping.confirm> [
                            { select = true; }
                        ];
                    };

                    sources = let
                        wrapNames = map (name: { inherit name; });
                    in
                        Call <cmp.config.sources> (map wrapNames [
                            [ "nvim_lsp" "luasnip" "nvim_lua" "omni" ]
                            [ "treesitter" ]
                            [ "buffer" "tmux" ]
                            [ "emoji" ]
                        ]);

                    view.entries = "native";

                    experimental.ghost_text = true;
                }])
            ]) { })

            vim-matchup
            (luaPlugin nvim-autopairs (Code [
                (SetLocal <autopairs> (Require "nvim-autopairs"))

                (Call <autopairs.setup> {
                    check_ts = true;
                    ts_config = { };
                })

                (Paste (map (L.o (Call <autopairs.add_rules>) Require) [
                    "nvim-autopairs.rules.endwise-elixir"
                    "nvim-autopairs.rules.endwise-lua"
                    "nvim-autopairs.rules.endwise-ruby" ]))

                (SetLocal <single_quote_rule>
                    (Index (Call <autopairs.get_rule> [ "'" ]) 1))

                (Call <table.insert> [
                    (Index <single_quote_rule> "not_filetypes")
                    "nix" ])

                (SetLocal <mk_autopairs_rules> (Function ({ }: [
                    (SetLocal <Rule> (Require "nvim-autopairs.rule"))
                    (SetLocal <cond> (Require "nvim-autopairs.conds"))
                    (SetLocal <ts_cond> (Require "nvim-autopairs.ts-conds"))

                    (ReturnOne [
                        # nix double single quotes
                        (Call <Rule> [ "''" "''" "nix" ])

                        # nix auto semicolon for bindings
                        (Chain (Call <Rule> [ "''" "''" "nix" ]) [
                            [ "with_pair" [
                                (Call <ts_cond.is_ts_node> [
                                    "ERROR" "binding" "binding_set"
                                    "attrset_expression" "formals" ])]]
                            [ "use_key" [ "<space>" ] ]
                            [ "replace_endpair" [
                                (Function ({ }: [
                                    (ReturnOne " ;<C-g>U<Left>") ]))]]
                            [ "with_cr" (Call <cond.none> []) ]])])])))
 
                (Call <autopairs.add_rules> (Call <mk_autopairs_rules> []))

                # cmp integration
                (SetLocal <autopairs_cmp>
                    (Require "nvim-autopairs.completion.cmp"))

                (CallOn <cmp.event> "on" [
                    "confirm_done"
                    (Call <autopairs_cmp.on_confirm_done> []) ])
            ]) { })

            # languages
            vim-slim

            # navigation
            (let
                glyphs = {
                    folder.arrow_closed = "▸";
                    folder.arrow_open = "▾";

                    git = {
                        unstaged  = "*"; staged    = "+"; unmerged  = "!";
                        renamed   = "~"; untracked = "?"; deleted   = "-";
                        ignored   = "#";
                    };
                };

                settings = {
                    hijack_cursor = true;

                    git.ignore = false;
                    modified.enable = true;
                    view.signcolumn = "auto";

                    renderer = {
                        highlight_opened_files = "name";
                        indent_markers.enable = true;

                        icons = {
                            inherit glyphs;
                            git_placement = "signcolumn";
                            show = { file = false; folder = false; };
                        };
                    };
                };

            in luaPlugin nvim-tree-lua (Code [
                (CallFrom (Require "nvim-tree") "setup" settings)

                (SetLocal <tree_api> (Require "nvim-tree.api"))

                (Call <vim.keymap.set> [ "n" "<leader>t" <tree_api.tree.toggle> ])
                (Call <vim.keymap.set> [ "n" "<leader>r" <tree_api.tree.reload> ])

                (Call <vim.keymap.set> [ "n" "<leader>n" (Function ({ }: [
                    (Call <tree_api.tree.find_file> { open = true; })])) ])

                (Call <vim.api.nvim_create_autocmd> [ "BufEnter" {
                    nested = true;
                    callback = Function ({ args }: [
                        (SetLocal <n_windows>
                            (Count (Call <vim.api.nvim_list_wins> [])))

                        (SetLocal <this_buf>
                            (Call <vim.api.nvim_get_current_buf> []))

                        (SetLocal <in_tree>
                            (Call <tree_api.tree.is_tree_buf> [ <this_buf> ]))

                        (If (And' [
                                (Ne <this_buf> 1)
                                (Eq <n_windows> 1)
                                <in_tree> ])
                           [ (Call <vim.cmd.quit> []) ]) ]);
                    }])
            ]) { })

            popup-nvim plenary-nvim

            (luaPlugin telescope-nvim (Code (let
                mkMapping = from: to:
                    (Call <vim.keymap.set> [ "n" from to ]);
            in [
                # telescope mappings
                (SetLocal <tb> (Require "telescope.builtin"))

                (mkMapping "<leader>ff" <tb.find_files>)
                (mkMapping "<leader>fg" <tb.live_grep>)
                (mkMapping "<leader>fb" <tb.buffers>)
                (mkMapping "<leader>fh" <tb.help_tags>)
            ])) { })

            # misc
            vim-sensible
            vim-startify
        ];
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
    };

}