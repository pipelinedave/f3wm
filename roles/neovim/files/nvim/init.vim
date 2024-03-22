" ============ Basic Setup ============
" Sets file encoding to UTF-8
set encoding=utf-8
" Tab character represents 4 spaces
set tabstop=4
" Auto-indent uses 4 spaces
set shiftwidth=4
" Replace tabs with spaces
set expandtab
" Keep at least 8 lines above/below the cursor
set scrolloff=8
" Enable relative line number
set relativenumber
" Set vertical scrolloff to 8
set scrolloff=8
" Set sidescrolloff to 8
set sidescrolloff=8
" Enable mouse support
set mouse=a
" Enable syntax highlighting
syntax on
" Enable filetype detection
filetype plugin indent on
" Set title to currently open file
set title
au BufEnter * let &titlestring = expand('%:t') . ' - nvim'
" ==========================================

" ============ Plugin Management ============
" Initialize vim-plug plugin manager
call plug#begin('~/.config/nvim/plugged')
" Add your plugins here between plug#begin and plug#end
" after adding anything, call :PlugInstall from within nvim
" ==========================================
" Add github-copilot plugin
" Plug 'github/copilot.vim'
" Add gruvbox theme
Plug 'morhetz/gruvbox'
" Add vim-airline plugin
Plug 'vim-airline/vim-airline'
" Add vim-airline-themes plugin
Plug 'vim-airline/vim-airline-themes'
" ==========================================
call plug#end()

" ============ Plugin Settings ============
" Enable copilot for all filetypes
" let g:copilot_filetypes = { '*': v:true }
" Set gruvbox theme
"" colorscheme gruvbox
" Set airline theme
"let g:airline_theme='gruvbox'
" Set airline to not show whitespace indicator
let g:airline#extensions#whitespace#enabled = 0
" Redefine airline section y (all about the file)
let g:airline_section_y = ''
" Redefine airline section z (all about the cursor)
let g:airline_section_z = airline#section#create_right(['%3p%%', '%l/%L', '%c'])
" ==========================================
