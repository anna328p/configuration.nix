{ pkgs, neovim, ... }:

{
	home = {
		packages = with pkgs; [
			solargraph
			haskell-language-server
			rnix-lsp
		];

		sessionVariables = {
			EDITOR = "nvim";
			VISUAL = "nvim";
		};
	};

	programs.neovim = {
		enable = true;
		package = neovim;

		extraConfig = ''
			set autoindent

			set clipboard+=unnamed
			set formatoptions+=j

			set hlsearch
			set ignorecase

			set mouse=a
			set ttimeoutlen=50
			set smartcase

			set number
			set background=dark
			set cursorline
			set ruler

			set title
			set noshowmode
			set showcmd
			set hidden
			set laststatus=2

			set splitbelow
			set splitright

			set scrolloff=3
			set sidescrolloff=5
			set wrap

			set copyindent
			set tabstop=4
			set shiftwidth=4
			set noexpandtab

			set undofile
			set undolevels=1000
			set undoreload=10000

			set completeopt=menu,menuone,noselect

			command! W :w
			command! Q :q


			" nord color scheme
			let g:nord_cursor_line_number_background = 1
			let g:nord_italic = 1
			let g:nord_italic_comments = 1
			let g:nord_underline = 1
			set termguicolors
			colorscheme nord
			set background=dark

			" airline
			let g:airline_powerline_fonts = 1
			let g:airline#extensions#tabline#enabled = 1
			let g:airline_detect_paste=1
			let g:airline_theme='nord'

			" Required after having changed the colorscheme
			hi clear SignColumn
			let g:airline#extensions#hunks#non_zero_only = 1

			" nvim tree
			nnoremap <leader>t :NvimTreeToggle<CR>
			nnoremap <leader>r :NvimTreeRefresh<CR>
			nnoremap <leader>n :NvimTreeFindFile<CR>

			let g:nvim_tree_icons = {
				\ 'folder': {'default': '▸', 'open': '▾', 'empty': '▸', 'empty_open': '▾'},
				\ }

			let g:nvim_tree_show_icons = {
				\ 'git': 0,
				\ 'folders': 1,
				\ 'files': 0,
				\ 'folder_arrows': 0,
				\ }

			lua <<EOF
				-- completions
				require'lspconfig'.solargraph.setup {}
				require'lspconfig'.hls.setup {}
				require'lspconfig'.rnix.setup {}

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
					},

					sources = cmp.config.sources(
						{ { name = 'nvim_lsp' }, { name = 'luasnip'} }, 
						{ { name = 'treesitter' }, },
						{ { name = 'buffer' }, { name = 'tmux' }, },
						{ { name = 'emoji' }, }
					),

					experimental = { native_menu = true, ghost_text = true },
				}

				-- treesitter
				require'nvim-treesitter.configs'.setup {
					ensure_installed = "maintained",
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

				require'treesitter-context.config'.setup { enable = true, }

				-- statusline
				require'lualine'.setup {
					options = {
						icons_enabled = false,
						theme = 'nord',
					},
				}

				-- file explorer
				require'nvim-tree'.setup {
					auto_close = true,
					hijack_cursor = true,
				}

				-- bracket matching
				require'pears'.setup()

				-- git gutter
				require'gitsigns'.setup { }

				-- show indentation levels
				require'indent_blankline'.setup {
					use_treesitter = true,
					show_trailing_blankline_indent = false,
				}
EOF
			" lint on file write
			au BufWritePost <buffer> lua require('lint').try_lint()

			" telescope mappings
			nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
			nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
			nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
			nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>
		'';
		plugins = with pkgs.vimPlugins; [
			# visual
			nord-vim gitsigns-nvim lualine-nvim
			nvim-colorizer-lua indent-blankline-nvim

			# completions
			nvim-lspconfig nvim-cmp
			cmp-nvim-lsp cmp-buffer cmp-tmux cmp-emoji cmp-treesitter
			luasnip cmp_luasnip

			copilot-vim

			# languages
			nvim-lint nvim-treesitter nvim-ts-rainbow nvim-treesitter-context
			vim-endwise pears-nvim

			# navigation
			nvim-tree-lua
			popup-nvim plenary-nvim telescope-nvim

			# misc
			vim-sensible vim-bracketed-paste
			vim-sneak vim-startify bclose-vim a-vim
		];
		viAlias = true;
		vimAlias = true;
		vimdiffAlias = true;
	};

}

# vim: set ts=4 sw=4 noet :
