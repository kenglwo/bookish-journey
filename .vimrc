" encoding
set encoding=utf-8 "the type of encoding used by Vim system
set fenc=utf-8 "the type of encoding used in a current buffer

"command
set showcmd
set laststatus=2
set wildmenu

"window
set number
set cursorline
set visualbell
set showmatch

"indent
set tabstop=4 "the length of <Tab> in a file
set expandtab "replace <Tab> to space
set softtabstop=4 "the length of space being put when you enter <Tab>
set autoindent
set smartindent
set shiftwidth=4 "the length of space automatically put by Vim

"text saerch
set hlsearch
set incsearch
set wrapscan

"recovery file
set swapfile
set backupdir=~/.vim/backup
set backup
" set viminfo=
if has('persistent_undo')
  set undodir=~/.vim/undo
  set undofile
endif

" move the last position of cursor when start vim
augroup vimrcEx
  au BufRead * if line("'\"") > 0 && line("'\"") <= line("$") |
  \ exe "normal g`\"" | endif
augroup END

"shortcuts for daily log
nnoremap <F6> <ESC>i---> <C-R>=strftime("%Y/%m/%d %H:%M")<CR> ---><CR>
nnoremap <F7> <ESC>i**** Today's WANT TO ****<CR>
nnoremap <F8> <ESC>i==== Today's Accomplishment! ====<CR>

"shortcuts for operating buffer
nnoremap <silent>bp :bprevious<CR>
nnoremap <silent>bn :bnext<CR>
nnoremap <silent>bf :bf<CR>
nnoremap <silent>bl :bl<CR>
nnoremap <silent>bb :b#<CR>
nnoremap <silent>bm :bm<CR>
nnoremap <silent>bd :bdelete<CR>

"meta key
let mapleader = "\<Space>"

"edit and quit
nnoremap <Leader>w :w<CR>
vmap     <Leader>y "+y
vmap     <Leader>d "+d
nmap     <Leader>p "+p
nmap     <Leader>P "+P
vmap     <Leader>p "+p
vmap     <Leader>P "+P
nnoremap <Leader>q :q<CR>
nnoremap <Leader>wq :wq<CR>

"grep with quickfix
autocmd QuickFixCmdPost *grep* cwindow


"dein---------------------------------------------------------------------
if &compatible
 set nocompatible
endif

let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif


if dein#load_state(s:dein_dir)
 call dein#begin(s:dein_dir)

 let s:toml_dir = expand('~/.cache/dein/plugins')
 call dein#load_toml(s:toml_dir . '/dein.toml', {'lazy': 0})
 call dein#load_toml(s:toml_dir . '/dein_lazy.toml', {'lazy': 1})
 call dein#add('~/.cache/dein')

 call dein#end()
 call dein#save_state()
endif


" If you want to install not installed plugins on startup.
if has('vim_starting') && dein#check_install()
  call dein#install()
endif
"---------------------------------------------------------------------------

filetype plugin indent on
syntax on
set background=dark
colorscheme PaperColor
" if (has("termguicolors"))
"  set termguicolors
" endif

nnoremap <silent><C-p> : PrevimOpen<CR>
