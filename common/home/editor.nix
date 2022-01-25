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
			filetype plugin indent on

			set autoread
			set backspace=indent,eol,start
			set clipboard+=unnamed
			set formatoptions+=j

			set hlsearch
			set ignorecase
			set incsearch

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

			set autoindent
			set copyindent
			set tabstop=4
			set shiftwidth=4
			set noexpandtab

			set undofile
			set undolevels=1000
			set undoreload=10000

			syntax on

			command! W :w
			command! Q :q


			let g:nord_cursor_line_number_background = 1
			let g:nord_italic = 1
			let g:nord_italic_comments = 1
			let g:nord_underline = 1
			set termguicolors
			colorscheme nord
			set background=dark

			"when entering a terminal enter in insert mode
			autocmd BufWinEnter,WinEnter term://* startinsert

			"airline
			let g:airline_powerline_fonts = 1
			let g:airline#extensions#tabline#enabled = 1
			let g:airline_detect_paste=1

			" Required after having changed the colorscheme
			hi clear SignColumn
			let g:airline#extensions#hunks#non_zero_only = 1

			nmap <silent> <leader>t :NERDTreeTabsToggle<CR>
			"let g:nerdtree_tabs_open_on_console_startup = 1

			let g:syntastic_error_symbol = 'E'
			let g:syntastic_warning_symbol = "W"
			augroup mySyntastic
				au!
				au FileType tex let b:syntastic_mode = "passive"
			augroup END

			" ----- xolox/vim-easytags settings -----
			" Where to look for tags files
			set tags=./tags;,~/.vimtags
			" Sensible defaults
			let g:easytags_events = ['BufReadPost', 'BufWritePost']
			let g:easytags_async = 1
			let g:easytags_dynamic_files = 2
			let g:easytags_resolve_links = 1
			let g:easytags_suppress_ctags_warning = 1

			nmap <silent> <leader>b :TagbarToggle<CR>
			let g:tagbar_ctags_bin = "${pkgs.universal-ctags}/bin/ctags"


			" ----- Raimondi/delimitMate settings -----
			let delimitMate_expand_cr = 1
			augroup mydelimitMate
				au!
				au FileType markdown let b:delimitMate_nesting_quotes = ["`"]
				au FileType tex let b:delimitMate_quotes = ""
				au FileType tex let b:delimitMate_matchpairs = "(:),[:],{:},`:'"
				au FileType python let b:delimitMate_nesting_quotes = ['"', "'"]
			augroup END"'"'"]"'"`

			call neomake#configure#automake('rw', 1000)

			lua <<EOF
				require'lspconfig'.solargraph.setup {}
				require'lspconfig'.hls.setup {}
				require'lspconfig'.rnix.setup {}

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
EOF

			let g:deoplete#enable_at_startup = 1
			let g:deoplete#buffer#require_same_filetype = 0
			inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
			autocmd CompleteDone * pclose

			if executable('rg')
				let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
				set grepprg=rg\ --vimgrep
			endif

			nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
			nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
			nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
			nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>
		'';
		plugins = with pkgs.vimPlugins; [
			base16-vim vim-gitgutter nord-vim

			# completions/neomake
			deoplete-nvim neco-vim nvim-lspconfig neomake neoinclude-vim neco-syntax
			deoplete-github deoplete-zsh deoplete-lsp

			copilot-vim

			vim-autoformat colorizer vim-airline vim-airline-themes

			# languages
			syntastic vim-nix nvim-treesitter nvim-ts-rainbow nvim-treesitter-context
			vim-rails vim-endwise delimitMate

			# misc
			nerdtree vim-nerdtree-tabs
			popup-nvim plenary-nvim telescope-nvim
			vim-dispatch vim-fugitive vim-rhubarb vim-sensible

			vim-sneak vim-surround vim-easytags vim-startify bclose-vim
			tmux-complete-vim vim-misc tagbar a-vim
		];
		viAlias = true;
		vimAlias = true;
		vimdiffAlias = true;
	};

}

# vim: set ts=4 sw=4 noet :
