{ pkgs, lib, L, config, systemConfig, ... }:

{
    home.sessionVariables.VISUAL = "nvim";

    programs.neovim = let
        pylancePath = ../../secrets/pylance.nix;

        pylanceExists = builtins.pathExists pylancePath;
        pylance = pkgs.callPackage pylancePath { };

        macros = with L.lua; let
            inherit (L.lua) __findFile;
        in rec {
            Call0 = fn: Call fn [ ];
            Call1 = fn: arg1: Call fn [ arg1 ];
            Call2 = fn: arg1: arg2: Call fn [ arg1 arg2 ];

            CallOn0 = fn: CallOn fn [ ];
            CallOn1 = fn: arg1: CallOn fn [ arg1 ];

            FromRequire = lib: CallFrom (Require lib);

            Setup = lib: CallFrom (Require lib) "setup";

            createUserCommand = name: command: opts:
                Call <vim.api.nvim_create_user_command>
                    [ name command opts ];

            createAutocmd = event: opts:
                Call <vim.api.nvim_create_autocmd>
                    [ event opts ];

            listWins =
                Call <vim.api.nvim_list_wins> [ ];

            getCurrentBuf =
                Call <vim.api.nvim_get_current_buf> [ ];

            getOptionValue = name: opts:
                Call <vim.api.nvim_get_option_value> [ name opts ];

            trim = Call1 <vim.trim>;

            tblExtend = behavior: tables:
                Call <vim.tbl_extend> ([ behavior ] ++ tables);

            tblDeepExtend = behavior: tables:
                Call <vim.tbl_deep_extend> ([ behavior ] ++ tables);

            keymap = rec {
                set = modes: lhs: rhs: opts:
                    Call <vim.keymap.set> [ modes lhs rhs opts ];

                set' = { modes, lhs, rhs, opts ? null }:
                    set modes lhs rhs opts;
            };

            lsp = {
                config = name: config:
                    Call <vim.lsp.config> [ name config ];

                enable = name:
                    Call <vim.lsp.enable> [ name ];

                getClientById = id:
                    Call <vim.lsp.get_client_by_id> [ id ];

                inlayHint = {
                    enable = flag:
                        Call <vim.lsp.inlay_hint.enable> [ flag ];
                };

                protocol = {
                    makeClientCapabilities =
                        Call <vim.lsp.protocol.make_client_capabilities> [];
                };

                buf = {
                    hover = config:
                        Call <vim.lsp.buf.hover> [ config ];
                };
            };

            diagnostic = {
                config = opts: namespace:
                    Call <vim.diagnostic.config> [ opts namespace ];

                openFloat = opts:
                    Call <vim.diagnostic.open_float> [ opts ];
            };

            loader = {
                enable = flag:
                    Call <vim.loader.enable> [ flag ];
            };
        };

    in {
        enable = true;
        defaultEditor = true;

        withRuby = false;
        withPython3 = false;

        extraPackages = let
            p = pkgs;
        in [
            p.neovim-ruby-env
            p.inotify-tools
            p.difftastic

            p.vscode-langservers-extracted
            p.bash-language-server
        ] ++ (lib.optionals systemConfig.misc.buildFull [
            p.ccls
            p.proselint

            p.nil p.statix
            p.haskell-language-server
            p.rust-analyzer p.clippy
            p.shellcheck
            p.pyright p.ruff
            p.vscode-extensions.vadimcn.vscode-lldb.adapter
            p.typescript-language-server p.prettier
        ]) ++ lib.optional pylanceExists pylance;

        initLua = let
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

                # pretty
                winblend = 10;

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

                # folding
                foldlevelstart = 99;

                # misc
                undofile = true;
                completeopt = [ "menu" "menuone" "noselect" ];

                # ripgrep
                grepprg = "${rg} --vimgrep --hidden --glob '!.git'";
            };

            inherit (L.lua) __findFile;

            inherit (L) mapSetEntries;

            M = macros;

        in with L.lua; Code [
            (Paste (mapSetEntries
                (k: v: (Set (Index <vim.opt> k) v))
                opts))

            (CallOn <vim.opt.clipboard> "append" [ "unnamed" ])

            # typo protection
            (M.createUserCommand "Q" "quit" {})
            (M.createUserCommand "W" "write <args>" { nargs = "*"; })

            # new cmdline
            (M.FromRequire "vim._core.ui2" "enable" {
                enable = true;
            })

            # experimental loader
            (M.loader.enable true)

            # diagnostics

            (M.diagnostic.config {
                virtual_text = false; # Turn off inline diagnostics
                underline = true;
                signs = true;
                severity_sort = true;

                float = {
                    source = "if_many";
                    show_header = false;
                    focusable = false;
                    max_width = 80;
                    border = "rounded";
                };

            } null)

            # open diagnostic float on cursor hover

            (Set <vim.opt.updatetime> 300)

            (M.createAutocmd "CursorHold" {
                callback = Function ({ }: [
                    (M.diagnostic.openFloat { })
                ]);
            })

            (M.keymap.set' {
                modes = "n";
                lhs = "K";
                rhs = Function ({ }: [
                    (Call <vim.lsp.buf.hover> { border = "rounded"; })
                ]);
                opts.desc = "Hover Documentation";
            })

            # define a textobject to select the entire file
            (M.keymap.set' {
                modes = [ "x" "o" ];
                lhs = "ae";
                rhs = ":<C-U>lockmarks normal! ggVG<CR>";
                opts.silent = true;
            })

            # keybind for lsp formatting
            (M.keymap.set "n" "grq" <vim.lsp.buf.format> null)
            (M.keymap.set "n" "grs" <vim.lsp.buf.signature_help> null)
        ];

        plugins = with L.lua; let
            v = pkgs.vimPlugins;

            luaPlugin = plugin: config: rest: {
                inherit plugin config;
                type = "lua";
            } // rest;

            prefixHashes = L.mapAttrValues (v: "#" + v);

            inherit (L.lua) __findFile;

            nvim-treesitter = v.nvim-treesitter.withAllGrammars;

            M = macros;
        in [
            # visual
            (luaPlugin v.base16-nvim (Code [
                (Set <vim.opt.termguicolors> true)
                (M.Setup "base16-colorscheme"
                    (prefixHashes config.colorScheme.palette))
            ]) { })

            (luaPlugin v.nvim-colorizer-lua (Code [
                (M.Setup "colorizer" {
                    user_default_options.mode = "virtualtext";
                })
            ]) { })

            (luaPlugin v.gitsigns-nvim (Code [
                (M.Setup "gitsigns" { })
            ]) { })

            v.copilot-lualine

            (luaPlugin v.lualine-nvim (Code [
                (M.Setup "lualine" {
                    options = {
                        icons_enabled = false;
                        theme = "base16";

                        sections.lualine_y = [ "copilot" "progress" ];
                    };
                 })
            ]) { })

            (luaPlugin v.tabline-nvim (Code [
                (M.Setup "tabline" {
                    options = {
                        show_devicons = false;
                        show_filename_only = true;
                    };
                 })
            ]) { })

            # telescope and such

            v.popup-nvim v.plenary-nvim

            v.telescope-ui-select-nvim

            (luaPlugin v.telescope-nvim (Code (let
                mkMapping = from: to:
                    M.keymap.set "n" from to null;
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
                        layout_strategy = "cursor";

                        layout_config = { width = 80; height = 8; };

                        border = true;
                    };
                } ])

                (CallFrom <telescope> "load_extension" [ "ui-select" ])
            ])) { })

            v.nvim-treesitter-endwise

            v.vim-matchup

            v.nvim-treesitter-textobjects

            (luaPlugin nvim-treesitter (Code [
                (Set <vim.g.matchup_treesitter_include_match_words> true)
                (Set <vim.g.matchup_treesitter_disable_virtual_text> false)

                (M.Setup "nvim-treesitter-textobjects" {
                    select = {
                        enable = true;
                        lookahead = true;

                        keymaps = {
                            "iT" = "@type.inner";
                            "aT" = "@type.outer";
                        };
                    };
                })

                (CallOn <vim.opt.runtimepath> "append"
                    [ ",${nvim-treesitter}/runtime" ])

                (Set <ts> <vim.treesitter>)

                (Set <ts_plugin> (Require "nvim-treesitter"))

                (Set <_G.ts_foldexpr> <vim.treesitter.foldexpr>)
                (Set <_G.ts_indentexpr> <ts_plugin.indentexpr>)

                (SetLocal <get_buffer_ft> (Function ({ buf }: [
                    (SetLocal <ft>
                        (M.getOptionValue "filetype" { inherit buf; }))

                    # For some reason it comes with some whitespace attached
                    (ReturnOne (M.trim <ft>))
                ])))

                (M.createAutocmd "FileType" {
                    desc = "Enable treesitter highlighting and indents";
                    callback = Function ({ args }: [
                        # Filetype of current buffer
                        (SetLocal <ft> (Call <get_buffer_ft> [ <args.buf> ]))

                        # If the language is available...
                        (If (Call <ts.language.add> [ <ft> ]) [
                            # enable treesitter highlighting, indents, folds
                            (Call <ts.start> [ ])
                            (Set <vim.bo.indentexpr> "v:lua.ts_indentexpr()")
                            (Set <vim.wo.foldexpr> "v:lua.ts_foldexpr()")
                            (Set <vim.wo.foldmethod> "expr")
                        ])
                    ]);
                } )
            ]) {
                runtime."after/queries/nix/injections.scm".source =
                    ./nvim/nix-injections.scm;
                runtime."after/queries/python/injections.scm".source =
                    ./nvim/python-injections.scm;
                runtime."after/queries/python/textobjects.scm".source =
                    ./nvim/python-textobjects.scm;
            })

            (luaPlugin v.nvim-treesitter-context (Code [
                (M.Setup "treesitter-context" {
                    enable = true;
                })
            ]) { })

            (luaPlugin v.indent-blankline-nvim (Code [
                # show indentation levels
                (M.Setup "ibl" {
                    indent.char = "│";

                    scope.show_start = false;
                    scope.show_end = false;

                    exclude.filetypes = [
                        "startify"
                    ];
                })
            ]) { })

            (luaPlugin v.nvim-surround (Code [
                (M.Setup "nvim-surround" { })
            ]) { })

            #vim-illuminate

            # language servers

            (luaPlugin v.nvim-lspconfig (Code [
                (SetLocal <lspconfig> (Require "lspconfig"))

                (SetLocal <lsp_caps> (M.lsp.protocol.makeClientCapabilities))

                (SetLocal <blink_caps>
                    (M.FromRequire "blink.cmp" "get_lsp_capabilities" []))

                (SetLocal <extra_caps> {
                    # file watching
                    workspace.didChangeWatchedFiles.dynamicRegistration = true;

                    # multiline semantic tokens
                    textDocument.semanticTokens.multilineTokenSupport = true;
                })

                (SetLocal <caps>
                    (M.tblDeepExtend "force"
                        [ <lsp_caps> <blink_caps> <extra_caps> ]))

                (M.lsp.config "*" { capabilities = <caps>; })

                (M.lsp.inlayHint.enable true)

                # HACK: lua.nix suffers from implicit formal arg sorting
                (SetLocal <setup_ls> (Function ({ name, settings }: [
                    (M.lsp.config name settings)
                    (M.lsp.enable name)
                ])))

                (M.Call2 <setup_ls> "pyright" (let
                    pylanceMagic = builtins.readFile
                        ../../secrets/pylance-license.json;
                in {
                    cmd = [ "${pylance}/bin/pylance" ];

                    init_options = {
                        clientVerification = pylanceMagic;
                    };

                    settings.python.analysis = {
                        languageServerMode = "default";
                        typeCheckingMode = "strict";
                        diagnosticMode = "workspace";
                        regenerateStdLibIndices = false;
                        enableExtractCodeAction = true;

                        inlayHints = {
                            variableTypes = true;
                            functionReturnTypes = true;
                            callArgumentNames = "partial";
                            pytestParameters = true;
                        };

                        autoFormatStrings = true;
                        autoImportCompletions = true;
                        nodeExecutable = "${pkgs.nodejs}/bin/node";
                    };
                }))

                (M.Call2 <setup_ls> "nil_ls" {
                    settings.nil = let
                        nixWrapped = pkgs.writeShellScript "nix-wrapped" ''
                            exec ${lib.getExe systemConfig.nix.package} \
                                --allow-import-from-derivation "$@"
                        '';
                    in {
                        diagnostics.ignored = [ "uri_literal" ];
                        nix = {
                            binary = "${nixWrapped}";
                            maxMemoryMB = 16384;

                            flake = {
                                autoArchive = true;
                                autoEvalInputs = true;
                            };
                        };
                    };
                })

                (M.Call2 <setup_ls> "ccls" {
                    single_file_support = true;
                })

                (M.Call2 <setup_ls> "ruby_lsp" {
                    cmd_env = {
                        BUNDLE_GEMFILE = "${../../pkgs/neovim-ruby-pkgs}/Gemfile";
                    };

                    init_options = {
                        linters = [ "rubocop" "reek" ];
                        formatter = "rubocop_internal";
                        experimentalFeaturesEnabled = true;
                    };
                })


                (SetLocal <auto_ls> [
                    "hls" "bashls" "cssls" 
                    "steep" "sorbet" "typeprof"
                    "pyright" "ruff"
                    "ts_ls" ])

                (ForEach (IPairs <auto_ls>) (_: name: [
                    (M.lsp.enable name)
                ]))

                # make nil-ls a semanticTokensProvider
                (M.createAutocmd "LspAttach" {
                    callback = Function ({ args }: [
                        (SetLocal <cid>
                            (Index' args [ "data" "client_id" ]))

                        (SetLocal <client>
                            (M.lsp.getClientById <cid>))

                        (If (Eq <client.name> "nil_ls") [
                            (Set (Index' <client> [
                                    "server_capabilities"
                                    "semanticTokensProvider" ])
                                null)
                        ])]);
                } )
            ]) { })

            (luaPlugin v.rustaceanvim (Code [
                (Set <vim.g.rustaceanvim> {
                    server.default_settings.rust-analyzer = {
                        procMacro = {
                            enable = true;
                            ignored = {
                                async-trait = [ "async_trait" ];
                                napi-derive = [ "napi" ];
                                async-recursion = [ "async_recursion" ];
                            };
                        };
                    };
                })
            ]) { })

            v.nvim-dap

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

                (Set <vim.g.guard_config> {
                    fmt_on_save = false;
                })
            ]) { })

            (luaPlugin v.nvim-lightbulb (Code [
                (M.Setup "nvim-lightbulb" {
                    autocmd.enabled = true;
                })
            ]) { })

            (luaPlugin v.actions-preview-nvim (Code [
                (SetLocal <hl> (Require "actions-preview.highlight"))

                (M.Setup "actions-preview" { })
            ]) { })

            # completions

            v.copilot-lsp

            (luaPlugin v.copilot-lua (Code [
                (M.Setup "copilot" {
                    suggestion.enabled = false;

                    panel = {
                        enabled = false;
                        auto_refresh = true;
                    };

                    nes = {
                        enabled = false;
                    };
                })
            ]) { })

            v.blink-copilot
            v.blink-compat
            v.blink-emoji-nvim
            v.blink-cmp-tmux

            v.cmp-treesitter

            (luaPlugin v.blink-cmp (Code [
                (M.Setup "blink.cmp" {
                    keymap = {
                        preset = "none";

                        "<C-space>" = [ "show" "select_and_accept" ];
                        "<C-e>" = [ "cancel" "fallback" ];

                        "<S-Tab>" = [ "select_prev" "fallback" ];
                        "<Tab>" = [ "select_next" "fallback" ];

                        "<Up>" = [ "select_prev" "fallback" ];
                        "<Down>" = [ "select_next" "fallback" ];

                        "<C-k>" = [ "show_signature" "hide_signature" "fallback" ];

                        "<C-b>" = [ "scroll_documentation_up" "fallback" ];
                        "<C-f>" = [ "scroll_documentation_down" "fallback" ];
                    };

                    completion = {
                        documentation = {
                            auto_show = true;
                        };

                        list.selection = {
                            preselect = false;
                            auto_insert = true;
                        };

                        menu.draw = {
                            columns = [
                                (Table' [
                                    [ "label" "label_description" ]
                                    { gap = 1; }
                                ])
                                [ "kind" ]
                                [ "source_id" ]
                            ];

                            components.label.width.max = 40;
                        };

                        ghost_text = {
                            enabled = true;
                            show_without_selection = true;
                        };

                        menu = {
                            border = "none";
                            draw.treesitter = [ "lsp" "copilot" ];
                        };
                    };

                    sources.default = [
                        "lsp" "path" "buffer" "omni"
                        "copilot" "treesitter" "tmux" "emoji"
                    ];

                    sources.providers = {
                        copilot = {
                            name = "copilot";
                            module = "blink-copilot";
                            score_offset = 100;
                            async = true;
                        };

                        emoji = {
                            name = "emoji";
                            module = "blink-emoji";
                            score_offset = -10;
                        };

                        treesitter = {
                            name = "treesitter";
                            module = "blink.compat.source";
                            score_offset = -50;
                        };

                        tmux = {
                            name = "tmux";
                            module = "blink-cmp-tmux";
                            score_offset = -50;
                        };
                    };

                    signature.enabled = true;
                })
            ]) { })

            (luaPlugin v.blink-pairs (Code [
                (M.Setup "blink-pairs" {
                    highlights.groups = [
                        "rainbowcol1"
                        "rainbowcol2"
                        "rainbowcol3"
                        "rainbowcol4"
                        "rainbowcol5"
                        "rainbowcol6"
                        "rainbowcol7"
                    ];
                })
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
                (M.Setup "nvim-tree" settings)

                (SetLocal <tree_api> (Require "nvim-tree.api"))

                (SetLocal <find_file_open> (Function ({ }: [
                    (Call <tree_api.tree.find_file> { open = true; })
                ])))

                (M.keymap.set "n" "<leader>t" <tree_api.tree.toggle> null)
                (M.keymap.set "n" "<leader>r" <tree_api.tree.reload> null)
                (M.keymap.set "n" "<leader>n" <find_file_open> null)

                (M.createAutocmd "BufEnter" {
                    nested = true;
                    callback = Function ({ args }: [
                        (SetLocal <n_windows> (Count (M.listWins)))

                        (SetLocal <this_buf> (M.getCurrentBuf))

                        (SetLocal <in_tree>
                            (Call <tree_api.tree.is_tree_buf> [ <this_buf> ]))

                        (If (And' [
                                (Ne <this_buf> 1)
                                (Eq <n_windows> 1)
                                <in_tree> ]) [
                            (Call <vim.cmd.quit> [])
                        ])
                    ]);
                })
            ]) { })

            # misc
            v.vim-sensible
            v.vim-startify
        ];
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
    };

}