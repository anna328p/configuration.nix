{ pkgs, lib, L, config, systemConfig, ... }:

{
    home.sessionVariables.VISUAL = "nvim";

    programs.neovim = let
        pylancePath = ../../secrets/pylance.nix;

        pylanceExists = builtins.pathExists pylancePath;
        pylance = pkgs.callPackage pylancePath { };
    in {
        enable = true;
        defaultEditor = true;

        withRuby = false;
        withPython3 = false;

        extraPackages = let
            p = pkgs;
            n = pkgs.nodePackages;

        in [
            p.neovim-ruby-env
            p.ccls

            n.vscode-langservers-extracted
            n.bash-language-server

            p.proselint
        ] ++ (lib.optionals systemConfig.misc.buildFull [
            p.nil p.statix
            p.haskell-language-server
            p.rust-analyzer
            p.shellcheck
            p.pyright
            p.ruff
        ]) ++ lib.optional pylanceExists pylance;

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

            inherit (L)
                o
                mapSetPairs
                uncurry
                ;
        in with L.lua; Code [
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


            # define a textobject to select the entire file
            (Call <vim.keymap.set> [ [ "x" "o" ] "ae" 
                ":<C-U>lockmarks normal! ggVG<CR>"
                { silent = true; }])

            # keybind for lsp formatting
            (Call <vim.keymap.set> [ [ "n" ] "grq" <vim.lsp.buf.format> ])
        ];

        plugins = with L.lua; let
            v = pkgs.vimPlugins;

            luaPlugin = plugin: config: rest: {
                inherit plugin config;
                type = "lua";
            } // rest;

            prefixHashes = L.mapAttrValues (v: "#" + v);

            inherit (L.lua) __findFile;
        in [
            # visual
            (luaPlugin v.base16-nvim (Code [
                (Set <vim.opt.termguicolors> true)
                (CallFrom (Require "base16-colorscheme") "setup"
                    (prefixHashes config.colorScheme.palette))
            ]) { })

            (luaPlugin v.nvim-colorizer-lua (Code [
                (CallFrom (Require "colorizer") "setup" {
                    user_default_options.mode = "virtualtext";
                })
            ]) { })

            (luaPlugin v.rainbow-delimiters-nvim (Code (let
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

                inherit (L) o mapSetPairs uncurry;
            in
                o mapSetPairs uncurry mkHighlight links
            )) { })

            (luaPlugin v.gitsigns-nvim (Code [
                (CallFrom (Require "gitsigns") "setup" { })
            ]) { })

            v.copilot-lualine

            (luaPlugin v.lualine-nvim (Code [
                (CallFrom (Require "lualine") "setup" {
                    options = {
                        icons_enabled = false;
                        theme = "base16";

                        sections.lualine_y = [ "copilot" "progress" ];
                    };
                 })
            ]) { })

            (luaPlugin v.tabline-nvim (Code [
                (CallFrom (Require "tabline") "setup" {
                    options = {
                        show_devicons = false;
                        show_filename_only = true;
                    };
                 })
            ]) { })

            v.nvim-treesitter-endwise

            v.vim-matchup

            v.nvim-treesitter-textobjects

            (luaPlugin v.nvim-treesitter.withAllGrammars (Code [
                (CallFrom (Require "nvim-treesitter.configs") "setup" {
                    highlight.enable = true;
                    indent.enable = true;
                    endwise.enable = true;

                    matchup = {
                        enable = true;
                        enable_quotes = true;
                        include_match_words = true;
                    };

                    textobjects = {
                        select = {
                            enable = true;
                            lookahead = true;

                            keymaps = {
                                "iT" = "@type.inner";
                                "aT" = "@type.outer";
                            };
                        };
                    };
                })
            ]) {
                runtime."after/queries/nix/injections.scm".source =
                    ./nvim/nix-injections.scm;
                runtime."after/queries/python/injections.scm".source =
                    ./nvim/python-injections.scm;
                runtime."after/queries/python/textobjects.scm".source =
                    ./nvim/python-textobjects.scm;
            })

            v.playground

            (luaPlugin v.nvim-treesitter-context (Code [
                (CallFrom (Require "treesitter-context") "setup" {
                    enable = true;
                })
            ]) { })

            (luaPlugin v.indent-blankline-nvim (Code [
                # show indentation levels
                (CallFrom (Require "ibl") "setup" {
                    indent.char = "│";

                    scope.show_start = false;
                    scope.show_end = false;

                    exclude.filetypes = [
                        "startify"
                    ];
                })
            ]) { })

            (luaPlugin v.nvim-surround (Code [
                (CallFrom (Require "nvim-surround") "setup" { })
            ]) { })

            #vim-illuminate

            # language servers

            v.cmp-nvim-lsp

            (luaPlugin v.nvim-lspconfig (Code [
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
                    "hls" "bashls" "cssls" "rust_analyzer"
                    "ruby_lsp" "pyright" "ruff" ])

                (ForEach (IPairs <auto_ls>) (_: name: [
                    (CallFrom (Index <lspconfig> name) "setup" {
                        capabilities = <caps>;
                    }) ]))


                (CallFrom (Index <lspconfig> "pyright") "setup" (
                    if pylanceExists then let
                        pylanceMagic = builtins.readFile
                            ../../secrets/pylance-license.json;
                    in {
                        cmd = [ "${pylance}/bin/pylance" ];

                        init_options = {
                            clientVerification = pylanceMagic;
                        };

                        settings.python.analysis.inlayHints = {
                            variableTypes = true;
                            functionReturnTypes = true;
                            callArgumentNames = true;
                            pytestParameters = true;
                        };

                        capabilities = <caps>;
                    } else {
                        capabilities = <caps>;
                    }
                ))


                (let
                    gemCmd = exe: test: args: [
                        "bash"
                        "-c"
                        ("bundle exec ${exe} ${test}"
                            + " && exec bundle exec ${exe} ${args}"
                            + " || exec ${exe} ${args}")
                    ];

                    rubyLS = name: cmd: extra:
                        CallFrom (Index <lspconfig> name) "setup" {
                            capabilities = <caps>;
                            inherit cmd;
                        } // extra;
                in
                    Paste [
                        (rubyLS "steep"
                            (gemCmd "steep" "--version" "langserver") { })

                        (rubyLS "typeprof"
                            (gemCmd "typeprof" "--version" "--lsp --stdio") { }) ])


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

                # make nil-ls a semanticTokensProvider
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

            v.guard-collection

            (let
                statixConfig = pkgs.mkNamedTOML.generate "statix.toml" {
                    disabled = [ "unquoted_uri" "empty_pattern" ];
                };

            in luaPlugin v.guard-nvim (Code [
                (SetLocal <ft> (Require "guard.filetype"))
                (SetLocal <lint> (Require "guard.lint"))

                (SetLocal <statix_lint> {
                    cmd = "statix";
                    args = [ "-c" "${statixConfig}" "-s" "-o" "json" ];
                    stdin = true;

                    parse = Call <lint.from_json> [ {
                        source = "statix";

                        get_diagnostics = Function ({ input }: [
                            (ReturnOne
                                (Index (Call <vim.json.decode> input) "report"))
                        ]);

                        attributes = let
                            dig = keys: Function ({ obj }: [
                                (ReturnOne (Index' obj keys))
                            ]);
                        in {
                            lnum = dig [ "diagnostics" 0 "at" "from" "line" ];
                            lnum_end = dig [ "diagnostics" 0 "at" "to" "line" ];
                            col = dig [ "diagnostics" 0 "at" "from" "column" ];
                            col_end = dig [ "diagnostics" 0 "at" "to" "column" ];
                            severity = "severity";
                            message = dig [ "diagnostics" 0 "message" ];
                            code = "code";
                        };

                        severities = {
                            Warn = <lint.severities.warning>;
                            Error = <lint.severities.error>;
                            Hint = <lint.severities.style>;
                        };
                    } ];
                })

                (Chain (Call <ft> [ "nix" ]) [
                    [ "lint" [ <statix_lint> ] ]
                ])

                (Chain (Call <ft> [ "sh,bash" ]) [
                    [ "lint" [ "shellcheck" ] ]
                ])

                (Chain (Call <ft> [ "python" ]) [
                    [ "lint" [ "lsp" ] ]
                    [ "fmt" [ "lsp" ] ]
                ])

                (CallFrom (Require "guard") "setup" [{
                    fmt_on_save = false;
                }])
            ]) { })

            # (let
            #     statixConfig = pkgs.mkNamedTOML.generate "statix.toml" {
            #         disabled = [ "unquoted_uri" "empty_pattern" ];
            #     };

            # in luaPlugin v.null-ls-nvim (Code [
            #     (SetLocal <null_ls> (Require "null-ls"))

            #     (CallFrom <null_ls> "setup" {
            #         sources = [
            #             <null_ls.builtins.diagnostics.shellcheck>
            #             <null_ls.builtins.code_actions.shellcheck>
            #             <null_ls.builtins.code_actions.statix>

            #             (CallFrom <null_ls.builtins.diagnostics.statix> "with" {
            #                 extra_args = [ "--config" "${statixConfig}" ];
            #             })
            #         ];
            #      })
            # ]) { })

            # completions
            v.luasnip v.cmp_luasnip v.cmp-nvim-lua
            v.cmp-omni
            v.cmp-treesitter
            v.cmp-buffer v.cmp-tmux
            v.cmp-emoji

            (luaPlugin v.copilot-lua (Code [
                (CallFrom (Require "copilot") "setup" [ {
                    suggestion.enabled = false;
                    panel = {
                        enabled = false;
                        auto_refresh = true;
                    };
                } ])
            ]) { })

            (luaPlugin v.copilot-cmp (Code [
                (CallFrom (Require "copilot_cmp") "setup" [])
            ]) { })

            (luaPlugin v.CopilotChat-nvim (Code [
                (CallFrom (Require "CopilotChat") "setup" [ {
                    auto_insert_mode = true;
                } ])
            ]) { })

            (luaPlugin v.nvim-cmp (Code [
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
                            [ "nvim_lsp" "nvim_lua" "omni" ]
                            [ "copilot" "luasnip" ]
                            [ "treesitter" ]
                            [ "buffer" "tmux" ]
                            [ "emoji" ]
                        ]);

                    view.entries = "native";

                    experimental.ghost_text = true;
                }])
            ]) { })

            (luaPlugin v.nvim-autopairs (Code [
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
            v.vim-slim

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

            in luaPlugin v.nvim-tree-lua (Code [
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

            v.popup-nvim v.plenary-nvim

            v.telescope-ui-select-nvim

            (luaPlugin v.telescope-nvim (Code (let
                mkMapping = from: to:
                    (Call <vim.keymap.set> [ "n" from to ]);
            in [
                (SetLocal <telescope> (Require "telescope"))
                (SetLocal <tb> (Require "telescope.builtin"))
                (SetLocal <tt> (Require "telescope.themes"))

                # telescope mappings
                (mkMapping "<leader>ff" <tb.find_files>)
                (mkMapping "<leader>fg" <tb.live_grep>)
                (mkMapping "<leader>fb" <tb.buffers>)
                (mkMapping "<leader>fh" <tb.help_tags>)

                (CallFrom <telescope> "setup" [ {
                    defaults = {
                        layout_config.vertical = { width = 80; height = 24; };
                    };

                    extensions.ui-select = {
                        sorting_strategy = "ascending";
                        layout_strategy = "bottom_pane";
                        layout_config.height = 8;
                        border = true;
                    };
                } ])

                (CallFrom <telescope> "load_extension" [ "ui-select" ])
            ])) { })

            # misc
            v.vim-sensible
            v.vim-startify
        ];
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
    };

}