
set nocompatible

" show the matching part of pairs [] {} and ()
set showmatch

" enable mouse support
" set mouse=a

" enable syntax
syntax on

" indent
"set autoindent
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
"filetype plugin indent on

" search
set hlsearch
set incsearch
set ignorecase
nnoremap <cr> :set hlsearch!<cr>

" edit
set wildmenu
set noswapfile
set listchars=tab:»■,trail:■
set list
set noerrorbells
set encoding=utf-8
set hidden

" appearance
"set number
set textwidth=80
set colorcolumn=80
set wrap
set showcmd
set showmode
set t_Co=256
" set termguicolors
colorscheme default
