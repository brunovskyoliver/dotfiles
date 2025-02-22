let g:jedi#show_call_signatures = 0
let mapleader = " "  
set expandtab
set scrolloff=3
set relativenumber
set shortmess+=F
set smarttab
set rtp+=/usr/local/opt/fzf
set nocompatible
set t_Co=256
set ai "indent
set si "indent
set wrap
set showmode
set showmatch
set hlsearch
set history=1000
set wildmenu
set wildmode=list:longest
set autoread
set backspace=eol,start,indent
set showmatch 
set mat=2
set noerrorbells
set novisualbell
set t_vb=
set tm=500
set number
set cursorline
set encoding=utf8
set ffs=unix,dos,mac
set nobackup
set nowb
set noswapfile
set ruler
filetype on
filetype plugin on
filetype plugin indent on
syntax on
syntax enable 
packloadall

" VimPlug
call plug#begin()
Plug 'KabbAmine/yowish.vim'
Plug 'romainl/vim-cool'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neoclide/coc-snippets'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'rose-pine/vim'
Plug 'prettier/vim-prettier', { 'do': 'yarn install --frozen-lockfile --production' }
Plug 'rhysd/vim-clang-format'
Plug 'mbbill/undotree'
Plug 'tpope/vim-fugitive'
call plug#end()
" EOF VimPlug

" Colorscheme
if has("termguicolors")
        set termguicolors
endif
colorscheme rosepine
highlight Normal       guibg=NONE ctermbg=NONE
highlight NormalFloat  guibg=NONE ctermbg=NONE
highlight NonText      guibg=NONE ctermbg=NONE
" EOF Colorscheme

" Coc
highlight! CocInlayHint ctermfg=yellow guifg=#ffff00
execute pathogen#infect()
augroup CustomColors
        autocmd!
        autocmd ColorScheme * highlight! CocInlayHint ctermfg=yellow guifg=#ffff00
augroup END
"autocmd BufWritePre *.go :silent call CocAction('runCommand', 'editor.action.organizeImport')
autocmd FileType go,c setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4
inoremap <silent><expr> <TAB>
                        \ coc#pum#visible() ? coc#pum#next(1) :
                        \ CheckBackspace() ? "\<Tab>" :
                        \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                        \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
function! CheckBackspace() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
endfunction
call coc#config('inlayHint', {
                        \ 'enable': v:false,
                        \})
nnoremap <silent> D :call ShowDocumentation()<CR>
function! ShowDocumentation()
        if CocAction('hasProvider', 'hover')
                call CocActionAsync('doHover')
        else
                call feedkeys('D', 'in')
        endif
endfunction
" EOF Coc

" Oldove remapy
nnoremap <leader>u :UndotreeToggle<CR>:wincmd w<CR>
nnoremap <leader>y "+Y
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
nnoremap J mzJ`z
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap =ap ma=ap'a
nnoremap Q <nop>
" velmi zaujimavy cmd
xnoremap <leader>p "_c<C-R>=substitute(getreg('+'),'\n$','','')<CR><Esc>
nnoremap <leader>d "_d
vnoremap <leader>d "_d
nnoremap <leader>s :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>
xnoremap <leader>r "sy:'<,'>s/\V<C-r>=escape(substitute(@s, '\n\+$', '', 'g'), '\/')<CR>//g<Left><Left>
nnoremap <leader>n :let @/ = '\<' . expand('<cword>') . '\>'<CR>n
command! -nargs=* W w
command! -nargs=* -complete=file E tabedit <args>
nnoremap <C-l> :Files<CR>
inoremap <C-l> <Esc>:Files<CR>
tnoremap <C-l> <C-\><C-N>:Files<CR>
" EOF Oldove remapy
let g:fzf_action = {
                        \ 'enter': 'tabedit',
                        \ 'ctrl-x': 'split',
                        \ 'ctrl-v': 'vsplit'
                        \ }


" Automatizacia pri zatvarani suborov
augroup AutoIndentParagraph
        autocmd!
        autocmd BufWritePre * normal! ma=ap'a
augroup END
autocmd BufReadPost *
                        \ if line("'\"") > 0 && line("'\"") <= line("$") |
                        \   exe "normal! g`\"" |
                        \ endif
set viminfo^=%
" EOF Automatizacia pri zatvarani suborov

" LaTeX
set shellslash
let g:tex_flavor='latex'
" EOF LaTeX

" Status_line 
set statusline=
set statusline+=\ %F\ %M\ %Y\ %R
set statusline+=%=
set statusline+=\ ascii:\ %b\ hex:\ 0x%B\ row:\ %l\ col:\ %c\ percent:\ %p%%
set laststatus=1
" EOF Status_line 

