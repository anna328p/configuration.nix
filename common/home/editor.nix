{ pkgs, flakes, forSystem, ... }:

{
	home = {
		packages = with pkgs; [
			solargraph
			haskell-language-server
			rnix-lsp
			nodePackages.diagnostic-languageserver
			nodePackages.vscode-langservers-extracted
			nodePackages.bash-language-server

			rubyPackages_3_1.rubocop
			proselint
		];

		sessionVariables = {
			EDITOR = "nvim";
			VISUAL = "nvim";
		};
	};

	programs.neovim = {
		enable = true;
		package = forSystem flakes.neovim.defaultPackage;
		withRuby = false;

		extraConfig = ''
			" integration
			set mouse=a
			set clipboard+=unnamed
			set title

			" searching
			set ignorecase
			set smartcase

			" view
			set number
			set cursorline
			set scrolloff=3
			set sidescrolloff=5

			" don't show mode twice
			set noshowmode

			" splits
			set splitbelow
			set splitright

			" indentation
			set copyindent
			set tabstop=4
			set shiftwidth=4
			set noexpandtab

			" misc
			set undofile
			set completeopt=menu,menuone,noselect

			" typo protection
			command! W :w
			command! Q :q

			" nord color scheme
			set termguicolors

			let g:nord_cursor_line_number_background = 1
			let g:nord_italic = 1
			let g:nord_italic_comments = 1
			let g:nord_underline = 1

			colorscheme nord
			set background=dark

			" nvim tree
			nnoremap <leader>t :NvimTreeToggle<CR>
			nnoremap <leader>r :NvimTreeRefresh<CR>
			nnoremap <leader>n :NvimTreeFindFile<CR>

			" nvim tree auto close if it's the last window
			autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif

			" open diagnostic float on cursor hover
			autocmd CursorHold * lua vim.diagnostic.open_float()
			set updatetime=300

			lua <<EOF
				-- completions
				local lspconfig = require'lspconfig'

				lspconfig.solargraph.setup {
					cmd = { 'bash', '-c', 'exec bundle exec solargraph stdio || solargraph stdio' },
				}

				lspconfig.hls.setup { }
				lspconfig.rnix.setup { }
				lspconfig.diagnosticls.setup { }
				lspconfig.bashls.setup { }

				local css_capabilities = vim.lsp.protocol.make_client_capabilities()
				css_capabilities.textDocument.completion.completionItem.snippetSupport = true

				lspconfig.cssls.setup {
					capabilities = css_capabilities,
				}

				local cmp = require'cmp'

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
						{ { name = 'nvim_lsp' }, { name = 'luasnip'} }, 
						{ { name = 'treesitter' }, },
						{ { name = 'buffer' }, { name = 'tmux' }, },
						{ { name = 'emoji' }, }
					),

					view = { entries = "native", },

					experimental = { ghost_text = true },
				}

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

				-- linting

				local null_ls = require'null-ls'

				null_ls.setup {
					sources = {
						-- null_ls.builtins.diagnostics.proselint,
					},
				}

				-- colors
				require'colorizer'.setup()

				-- treesitter
				require'nvim-treesitter.configs'.setup {
					ensure_installed = { },
					rainbow = { enable = true, extended_mode = true, },
					highlight = { enable = true, },
					indent = { enable = true, },

					incremental_selection = {
						enable = true,
						keymaps = {
							init_selection = "gnn",
							node_incremental = "grn",
							scope_incremental = "grc",
							node_decremental = "grm",
						},
					},
				}

				require'treesitter-context'.setup { enable = true, }

				-- statusline
				require'lualine'.setup {
					options = {
						icons_enabled = false,
						theme = 'nord',
					},
				}

				require'tabline'.setup {
					options = {
						show_devicons = false,
						show_filename_only = true,
					},
				}

				-- file explorer
				require'nvim-tree'.setup {
					hijack_cursor = true,

					renderer = {
						icons = {
							glyphs = { folder = { default = '▸', open = '▾', empty = '▸', empty_open = '▾' }, },
							show = { file = false, folder = true, folder_arrow = false, git = false },
						},
					},
				}

				-- bracket matching
				require'pears'.setup(function(conf)
					conf.remove_pair_on_outer_backspace(false)
				end)

				-- git gutter
				require'gitsigns'.setup { }

				-- show indentation levels
				require'indent_blankline'.setup {
					use_treesitter = true,
					show_trailing_blankline_indent = false,
					show_current_context = true,
				}
EOF
			" telescope mappings
			nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
			nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
			nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
			nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>
		'';
		plugins = with pkgs.vimPlugins; let
			vim-slim = pkgs.vimUtils.buildVimPlugin {
				pname = "vim-slim";
				version = "unstable";

				src = pkgs.fetchFromGitHub {
					owner = "slim-template";
					repo = "vim-slim";
					rev = "f0758ea1c585d53b9c239177a8b891d8bbbb6fbb";
					sha256 = "dkFTxBi0JAPuIkJcVdzE8zUswHP0rVZqiCE6NMywDm8=";
				};
			};

			nvim-treesitter-all = nvim-treesitter.withPlugins (plugins:
				pkgs.tree-sitter.allGrammars
			);
		in [
			# visual
			nord-vim gitsigns-nvim lualine-nvim tabline-nvim
			nvim-colorizer-lua indent-blankline-nvim

			# completions
			nvim-lspconfig nvim-cmp
			cmp-nvim-lsp cmp-buffer cmp-tmux cmp-emoji cmp-treesitter
			luasnip cmp_luasnip

			# copilot-vim # currently broken

			# linting
			null-ls-nvim

			# syntax
			nvim-treesitter-all nvim-ts-rainbow nvim-treesitter-context
			vim-endwise pears-nvim

			# languages
			vim-slim

			# navigation
			nvim-tree-lua
			popup-nvim plenary-nvim telescope-nvim

			# misc
			vim-sensible vim-bracketed-paste vim-surround
			vim-startify bclose-vim a-vim
		];
		viAlias = true;
		vimAlias = true;
		vimdiffAlias = true;
	};

}

# vim: set ts=4 sw=4 noet :
