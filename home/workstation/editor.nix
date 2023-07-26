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
            nixd nil statix deadnix

            nodePackages.vscode-langservers-extracted
            nodePackages.bash-language-server

            rubyPackages_latest.rubocop
            proselint
        ] ++ (lib.optionals systemConfig.misc.buildFull (with pkgs; [
            haskell-language-server
            rust-analyzer
            shellcheck
        ]));

        extraLuaConfig = let
            rg = lib.getExe pkgs.ripgrep;
        in /* lua */ ''
            -- integration
            vim.opt.mouse = 'a'
            vim.opt.clipboard:append('unnamed')
            vim.opt.title = true

            -- searching
            vim.opt.ignorecase = true
            vim.opt.smartcase = true

            -- view
            vim.opt.number = true
            vim.opt.cursorline = true
            vim.opt.scrolloff = 3
            vim.opt.sidescrolloff = 5

            -- don't show mode twice
            vim.opt.showmode = false

            -- splits
            vim.opt.splitbelow = true
            vim.opt.splitright = true

            -- indentation
            vim.opt.copyindent = true
            vim.opt.tabstop = 4
            vim.opt.shiftwidth = 4
            vim.opt.expandtab = false

            -- misc
            vim.opt.undofile = true
            vim.opt.completeopt = { 'menu', 'menuone', 'noselect', }

            -- typo protection
            vim.api.nvim_create_user_command('Q', 'quit', { })
            vim.api.nvim_create_user_command('W', 'write <args>', {
                nargs = '*',
            })

            -- ripgrep
            vim.opt.grepprg = "${rg} --vimgrep --hidden --glob '!.git'"

            -- diagnostics

            vim.diagnostic.config({
                virtual_text = false, -- Turn off inline diagnostics
                underline = true,
                signs = true,
                severity_sort = true,

                float = {
                    source = 'if_many',
                    show_header = true,
                    focusable = false,
                    max_width = 80,
                },
            })

            -- open diagnostic float on cursor hover
            vim.opt.updatetime = 300
            vim.api.nvim_create_autocmd('CursorHold', {
                callback = function()
                    vim.diagnostic.open_float()
                end,
            })
        '';

        plugins = with pkgs.vimPlugins; let
            luaPlugin = plugin: config: rest: {
                inherit plugin config;
                type = "lua";
            } // rest;

            prefixHashes = L.mapAttrValues (v: "#" + v);
            base16Colors = with L;
                toLuaLiteral (prefixHashes config.colorScheme.colors);
        in [
            # visual
            (luaPlugin nvim-base16 /* lua */ ''
                vim.opt.termguicolors = true
                require('base16-colorscheme').setup(${base16Colors})
            '' { })

            (luaPlugin nvim-colorizer-lua /* lua */ ''
                -- colorize color codes
                require('colorizer').setup {
                    user_default_options = {
                        mode = 'virtualtext',
                    },
                }
            '' { })

            (luaPlugin rainbow-delimiters-nvim /* lua */ ''
                -- hlgroup links

                local mk_hl_link = function (group, target)
                    vim.api.nvim_set_hl(0, group, { link = target })
                end

                mk_hl_link('RainbowDelimiterRed',    'rainbowcol1')
                mk_hl_link('RainbowDelimiterYellow', 'rainbowcol2')
                mk_hl_link('RainbowDelimiterBlue',   'rainbowcol3')
                mk_hl_link('RainbowDelimiterOrange', 'rainbowcol4')
                mk_hl_link('RainbowDelimiterGreen',  'rainbowcol5')
                mk_hl_link('RainbowDelimiterViolet', 'rainbowcol6')
                mk_hl_link('RainbowDelimiterCyan',   'rainbowcol7')
            '' { })

            (luaPlugin gitsigns-nvim /* lua */ ''
                require('gitsigns').setup { }
            '' { })

            (luaPlugin lualine-nvim /* lua */ ''
                require('lualine').setup {
                    options = {
                        icons_enabled = false,
                        theme = 'base16',
                    },
                }
            '' { })

            (luaPlugin tabline-nvim /* lua */ ''
                require('tabline').setup {
                    options = {
                        show_devicons = false,
                        show_filename_only = true,
                    },
                }
            '' { })

            nvim-treesitter-endwise

            (luaPlugin nvim-treesitter.withAllGrammars /* lua */ ''
                require('nvim-treesitter.configs').setup {
                    highlight = { enable = true, },
                    indent = { enable = true, },
                    endwise = { enable = true, },
                }
            '' {
                runtime."after/queries/nix/injections.scm".source =
                    ./nvim/nix-injections.scm;
            })

            playground

            (luaPlugin nvim-treesitter-context /* lua */ ''
                require('treesitter-context').setup { enable = true, }
            '' { })

            (luaPlugin indent-blankline-nvim /* lua */ ''
                -- show indentation levels
                require('indent_blankline').setup {
                    use_treesitter = true,
                    show_trailing_blankline_indent = false,
                    show_current_context = true,
                }
            '' { })

            (luaPlugin nvim-surround /* lua */ ''
                require('nvim-surround').setup { }
            '' { })

            #vim-illuminate

            # language servers

            cmp-nvim-lsp

            (luaPlugin nvim-lspconfig /* lua */ ''
                -- completions
                local lspconfig = require 'lspconfig'

                local lsp_caps = vim.lsp.protocol.make_client_capabilities()
                local cmp_caps = require('cmp_nvim_lsp').default_capabilities()

                local file_watching_cap = {
                    workspace = { 
                        didChangeWatchedFiles = { dynamicRegistration = true }
                    }
                }

                local caps = vim.tbl_deep_extend(
                    'force',
                    lsp_caps,
                    cmp_caps,
                    file_watching_cap)

                lspconfig.solargraph.setup {
                    cmd = {
                        'bash',
                        '-c',
                        'bundle exec solargraph --version'
                            .. ' && exec bundle exec solargraph stdio'
                            .. ' || solargraph stdio',
                    },
                    capabilities = cmp_caps,
                }

                lspconfig.hls.setup { capabilities = cmp_caps, }

                lspconfig.nil_ls.setup {
                    capabilities = cmp_caps,
                    settings = {
                        ['nil'] = {
                            diagnostics = {
                                ignored = { "uri_literal", },
                            },
                            nix = { flake = { autoEvalInputs = true } },
                        },
                    },
                }

                lspconfig.bashls.setup { capabilities = cmp_caps, }
                lspconfig.cssls.setup { capabilities = cmp_caps, }
                lspconfig.rust_analyzer.setup { capabilities = cmp_caps, }

                lspconfig.ccls.setup {
                    capabilities = cmp_caps,
                    single_file_support = true,
                }

                vim.api.nvim_create_autocmd('LspAttach', {
                    callback = function(args)
                        local cid = args.data.client_id
                        local client = vim.lsp.get_client_by_id(cid)

                        if client.name == 'nil_ls' then
                            client.server_capabilities
                                  .semanticTokensProvider = nil
                        end
                    end,
                })
            '' { })

            (let
                statixConfig = pkgs.mkNamedTOML.generate "statix.toml" {
                    disabled = [ "unquoted_uri" ];
                };

            in luaPlugin null-ls-nvim /* lua */ ''
                -- linting
                local null_ls = require 'null-ls'

                null_ls.setup {
                    sources = {
                        null_ls.builtins.diagnostics.deadnix,
                        null_ls.builtins.diagnostics.shellcheck,
                        null_ls.builtins.diagnostics.statix.with {
                            extra_args = { '--config', '${statixConfig}' },
                        },

                        null_ls.builtins.code_actions.shellcheck,
                        null_ls.builtins.code_actions.statix,
                    },
                }
            '' { })

            # completions
            luasnip cmp_luasnip cmp-nvim-lua
            cmp-omni
            cmp-treesitter
            cmp-buffer cmp-tmux
            cmp-emoji

            (luaPlugin nvim-cmp /* lua */ ''
                -- completions

                local cmp = require 'cmp'

                cmp.setup {
                    snippet = {
                        expand = function(args)
                            require('luasnip').lsp_expand(args.body)
                        end,
                    },

                    mapping = {
                        ['<C-e>'] = cmp.mapping.close(),

                        ['<Tab>'] = cmp.mapping(
                            function(fallback)
                                if cmp.visible() then
                                    cmp.select_next_item()
                                else
                                    fallback()
                                end
                            end,
                            { 'i', 's' }
                        ),
                        
                        ["<S-Tab>"] = cmp.mapping(
                            function()
                                if cmp.visible() then
                                    cmp.select_prev_item()
                                else
                                    fallback()
                                end
                            end,
                            { 'i', 's' }
                        ),

                        ['<C-Space>'] = cmp.mapping.confirm({ select = true }),
                    },

                    sources = cmp.config.sources(
                        {
                            { name = 'nvim_lsp' },
                            { name = 'luasnip' },
                            { name = 'nvim_lua' },
                            { name = 'omni' }
                        },
                        {
                            { name = 'treesitter' },
                        },
                        {
                            { name = 'buffer' },
                            { name = 'tmux' },
                        },
                        {
                            { name = 'emoji' },
                        }
                    ),

                    view = { entries = "native", },

                    experimental = { ghost_text = true },
                }
            '' { })

            vim-matchup
            (luaPlugin nvim-autopairs /* lua */ ''
                -- bracket matching

                local autopairs = require 'nvim-autopairs' 

                autopairs.setup {
                    check_ts = true,
                    ts_config = { },
                }

                autopairs.add_rules(require 'nvim-autopairs.rules.endwise-elixir')
                autopairs.add_rules(require 'nvim-autopairs.rules.endwise-lua')
                autopairs.add_rules(require 'nvim-autopairs.rules.endwise-ruby')

                local single_quote_rule = autopairs.get_rule("'")[1]
                table.insert(single_quote_rule.not_filetypes, 'nix')

                local mk_autopairs_rules = function()
                    local Rule = require 'nvim-autopairs.rule' 
                    local cond = require 'nvim-autopairs.conds' 
                    local ts_cond = require 'nvim-autopairs.ts-conds' 

                    return {
                        -- nix double single quotes
                        Rule("'''", "'''", 'nix'),

                        -- nix auto semicolon for bindings
                        Rule('=', ';', 'nix')
                            :with_pair(ts_cond.is_ts_node {
                                'ERROR',
                                'binding',
                                'binding_set',
                                'attrset_expression',
                                'formals',
                            })
                            :with_cr(cond.none()),

                        Rule('let', 'in', 'nix')
                            :only_cr(cond.done()),

                        Rule('let ', ' in', 'nix')
                            :with_pair(cond.not_inside_quote())
                            :with_move(cond.none())
                            :replace_map_cr(function()
                                -- 1. start new undo block
                                -- 2. insert a newline, move one word right
                                -- 3. exit insert mode, move up, open above
                                return '<C-g>u<CR><C-Right><CR><C-c>kO'
                            end),

                        Rule('rec {', '}', 'nix')
                            :with_pair(cond.not_inside_quote())
                            :set_end_pair_length(1),
                    }
                end

                autopairs.add_rules(mk_autopairs_rules())

                -- cmp integration
                local autopairs_cmp = require 'nvim-autopairs.completion.cmp' 
                cmp.event:on('confirm_done', autopairs_cmp.on_confirm_done())
            '' { })

            # languages
            vim-slim

            # navigation
            (luaPlugin nvim-tree-lua /* lua */ ''
                -- file explorer
                local nvim_tree_glyphs = {
                    folder = { arrow_closed = '▸', arrow_open = '▾', },

                    git = {
                        unstaged  = '*', staged    = '+', unmerged  = '!',
                        renamed   = '~', untracked = '?', deleted   = '-',
                        ignored   = '#',
                    },
                }

                require('nvim-tree').setup {
                    hijack_cursor = true,

                    git      = { ignore = false, },
                    modified = { enable = true, },
                    view     = { signcolumn = "auto", },

                    renderer = {
                        highlight_opened_files = 'name',
                        indent_markers = { enable = true, },

                        icons = {
                            glyphs = nvim_tree_glyphs,
                            git_placement = 'signcolumn',
                            show = { file = false, folder = false, },
                        },
                    },
                }

                local tree_api = require 'nvim-tree.api'

                vim.keymap.set('n', '<leader>t', tree_api.tree.toggle)
                vim.keymap.set('n', '<leader>r', tree_api.tree.reload)

                vim.keymap.set('n', '<leader>n', function()
                    tree_api.tree.find_file { open = true, }
                end)

                -- auto close nvim-tree if it's the last window
                vim.api.nvim_create_autocmd('BufEnter', {
                    nested = true,
                    callback = function(args)
                        local n_windows = #vim.api.nvim_list_wins()
                        local this_buf = vim.api.nvim_get_current_buf()

                        local in_tree = tree_api.tree.is_tree_buf(this_buf)

                        if n_windows == 1 and in_tree then
                            vim.cmd.quit()
                        end
                    end,
                })
            '' { })

            popup-nvim plenary-nvim
            (luaPlugin telescope-nvim /* lua */ ''
                -- telescope mappings
                local tb = require 'telescope.builtin'
                vim.keymap.set('n', '<leader>ff', tb.find_files)
                vim.keymap.set('n', '<leader>fg', tb.live_grep)
                vim.keymap.set('n', '<leader>fb', tb.buffers)
                vim.keymap.set('n', '<leader>fh', tb.help_tags)
            '' { })

            # misc
            vim-sensible
            vim-startify
        ];
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
    };

}