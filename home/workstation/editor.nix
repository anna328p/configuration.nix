{ pkgs, lib, L, config, systemConfig, ... }:

{
    home = {
        packages = with pkgs; [
            rubyPackages_latest.solargraph
            ccls
            nixd

            nodePackages.vscode-langservers-extracted

            nodePackages.bash-language-server
            shellcheck

            nodePackages.diagnostic-languageserver
            rubyPackages_latest.rubocop
            proselint
        ] ++ (lib.optionals systemConfig.misc.buildFull (with pkgs; [
            haskell-language-server
        ]));

        sessionVariables = {
            EDITOR = "nvim";
            VISUAL = "nvim";
        };
    };

    xdg.configFile."nvim/after/queries/nix/injections.scm".text = /* query */ ''
        ; extends
        
        ((
          ((comment) @language)
          (#gsub! @language "/%*%s*(.-)%s*%*/" "%1")
          (#gsub! @language "#%s*(.*)" "%1")
          .
          (indented_string_expression (string_fragment) @content))) @combined
        '';

    programs.neovim = {
        enable = true;
        withRuby = false;

        extraLuaConfig = let
            rg = lib.getExe pkgs.ripgrep;
            cc = lib.getExe pkgs.stdenv.cc;

            prefixHashes = L.mapAttrValues (v: "#" + v);

            base16Colors = with L;
                toLuaLiteral (prefixHashes config.colorScheme.colors);
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

            -- color scheme
            vim.opt.termguicolors = true
            vim.opt.background = 'dark'

            require('base16-colorscheme').setup(${base16Colors})

            -- colorize color codes
            local colorizer = require 'colorizer'
            colorizer.setup()

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

            -- treesitter

            -- make sure parsers can compile
            local ts_install = require 'nvim-treesitter.install'
            ts_install.compilers = { '${cc}' }

            require('nvim-treesitter.configs').setup {
                highlight = { enable = true, },
                indent = { enable = true, },
                endwise = { enable = true, },
            }

            require('treesitter-context').setup { enable = true, }

            -- git gutter
            require('gitsigns').setup { }

            -- show indentation levels
            require('indent_blankline').setup {
                use_treesitter = true,
                show_trailing_blankline_indent = false,
                show_current_context = true,
            }

            -- file explorer
            local nvim_tree = require 'nvim-tree'

            nvim_tree.setup {
                hijack_cursor = true,

                git = {
                    enable = true,
                    ignore = false,
                },

                modified = { enable = true, },

                view = { signcolumn = "auto", },

                renderer = {
                    highlight_opened_files = 'name',

                    indent_markers = {
                        enable = true,
                        inline_arrows = true,
                    },

                    icons = {
                        show = {
                            file = false,
                            folder = false,
                            folder_arrow = true,
                        },

                        git_placement = 'signcolumn',

                        glyphs = {
                            folder = {
                                arrow_closed = '▸',
                                arrow_open = '▾',
                            },

                            git = {
                                unstaged  = '~',
                                staged    = '+',
                                unmerged  = '!',
                                renamed   = '*',
                                untracked = '?',
                                deleted   = '-',
                                ignored   = '#',
                            },
                        },
                    },
                },
            }

            -- mk_hl_alias('NvimTreeIndentMarker', 'IndentBlanklineChar')

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
                    local cur = vim.api.nvim_get_current_buf()

                    local cur_buf_is_tree = tree_api.tree.is_tree_buf(this_buf)

                    if n_windows == 1 and cur_buf_is_tree then
                        vim.cmd.quit()
                    end
                end,
            })

            -- telescope mappings
            local tb = require 'telescope.builtin'
            vim.keymap.set('n', '<leader>ff', tb.find_files)
            vim.keymap.set('n', '<leader>fg', tb.live_grep)
            vim.keymap.set('n', '<leader>fb', tb.buffers)
            vim.keymap.set('n', '<leader>fh', tb.help_tags)

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

            -- completions

            local cmp = require 'cmp'

            cmp.setup {
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end,
                },

                mapping = {
                    ["<C-e>"] = cmp.mapping.close(),

                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        else
                            fallback()
                        end
                    end, {"i", "s"}),
                    
                    ["<S-Tab>"] = cmp.mapping(function()
                        if cmp.visible() then
                            cmp.select_prev_item()
                        else
                            fallback()
                        end
                    end, {"i", "s"}),

                    ['<C-Space>'] = cmp.mapping.confirm({ select = true }),
                },

                sources = cmp.config.sources(
                    {
                        { name = 'nvim_lsp' },
                        { name = 'luasnip' },
                        { name = 'nvim_lua' }
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

            -- completions
            local lspconfig = require 'lspconfig'
            local cmp_caps = require('cmp_nvim_lsp').default_capabilities()

            lspconfig.solargraph.setup {
                cmd = {
                    'bash',
                    '-c',
                    'bundle exec solargraph --version'
                        .. ' && exec bundle exec solargraph stdio'
                        .. ' || solargraph stdio'
                },
                capabilities = cmp_caps,
            }

            lspconfig.hls.setup {
                capabilities = cmp_caps,
            }

            lspconfig.nixd.setup {
                capabilities = cmp_caps,
            }

            lspconfig.diagnosticls.setup {
                capabilities = cmp_caps,
            }

            lspconfig.bashls.setup {
                capabilities = cmp_caps,
            }

            lspconfig.ccls.setup {
                capabilities = cmp_caps,
                single_file_support = true,
            }

            lspconfig.cssls.setup {
                capabilities = cmp_caps,
            }

            -- linting

            local null_ls = require 'null-ls'

            null_ls.setup {
                sources = {
                    -- null_ls.builtins.diagnostics.proselint,
                },
            }


            -- statusline
            require('lualine').setup {
                options = {
                    icons_enabled = false,
                    theme = 'base16',
                },
            }

            require('tabline').setup {
                options = {
                    show_devicons = false,
                    show_filename_only = true,
                },
            }

            -- bracket matching

            local autopairs = require 'nvim-autopairs' 
            local ap_rule = require 'nvim-autopairs.rule' 

            autopairs.setup {
                check_ts = true,
                ts_config = { },
            }

            -- nix double single quotes
            autopairs.add_rule(ap_rule("'''", "'''", 'nix'))

            autopairs.add_rules(require 'nvim-autopairs.rules.endwise-elixir')
            autopairs.add_rules(require 'nvim-autopairs.rules.endwise-lua')
            autopairs.add_rules(require 'nvim-autopairs.rules.endwise-ruby')

            -- cmp integration
            local autopairs_cmp = require 'nvim-autopairs.completion.cmp' 
            cmp.event:on('confirm_done', autopairs_cmp.on_confirm_done())

            -- surround
            require('nvim-surround').setup { }
        '';

        plugins = with pkgs.vimPlugins; [
            # visual
            nvim-base16 gitsigns-nvim lualine-nvim tabline-nvim
            nvim-colorizer-lua indent-blankline-nvim

            # completions
            nvim-lspconfig nvim-cmp
            cmp-nvim-lsp cmp-nvim-lua cmp-treesitter
            cmp-buffer cmp-tmux cmp-emoji
            luasnip cmp_luasnip

            # linting
            null-ls-nvim

            # syntax
            nvim-treesitter.withAllGrammars
            nvim-treesitter-context playground
            nvim-autopairs nvim-treesitter-endwise
            pkgs.rainbow-delimiters-nvim

            # languages
            pkgs.vim-slim

            # navigation
            nvim-tree-lua
            popup-nvim plenary-nvim telescope-nvim

            # misc
            vim-sensible vim-bracketed-paste nvim-surround
            vim-startify bclose-vim a-vim
        ];
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
    };

}