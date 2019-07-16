syntax enable
set background=dark
colorscheme desert256

" An example for a vimrc file.
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc
"

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible
let mapleader=","

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
set tabpagemax=20

" Don't use Ex mode, use Q for formatting
nmap Q gqip
vmap Q gq

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78 fo=troqwanl1c ai equalprg=cat
  autocmd FileType text setlocal formatlistpat=^\\s*[0-9*\\-\\+=]\\+[\\]:.)}\\t\ ]\\s*
  "autocmd FileType text setlocal formatlistpat='^\s*[0-9*\-\+=]\+[\]:.)}\t\ ]\s*'


  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
              \ if line("'\"") > 0 && line("'\"") <= line("$") |
              \  exe "normal g`\"" |
              \ endif
  augroup END

else

  set autoindent		" always set autoindenting on
  set smartindent

endif " has("autocmd")

set colorcolumn=+1
highlight ColorColumn ctermbg=234

" Email
autocmd FileType mail vnoremap m <Esc>:nohl<cr>gg}v/^-- <cr>k
autocmd FileType mail omap m :normal Vm<cr>

" Markdown
augroup mkd
        " autocmd BufRead *.mkd  set ai formatoptions=tcroqn2 comments=n:&gt;
        autocmd BufRead *.mkd  set ai formatoptions=tcroqnw1 tw=70 comments=n:&gt;
augroup END

set tabstop=4
set shiftwidth=4
set expandtab
set textwidth=78
set nowrap

augroup csv
        autocmd BufRead *.csv set noai tw=0 formatoptions=l noexpandtab list tabstop=4 shiftwidth=4
augroup END

augroup todo
  autocmd FileType todo setlocal noai tw=0 formatoptions=l
augroup END

" Set Level 1 Heading Underline
nnoremap <F5> yyp<c-v>$r=
inoremap <F5> <Esc>yyp<c-v>$r=A

" Set Level 2 Heading Underline
nnoremap <F6> yyp<c-v>$r-
inoremap <F6> <Esc>yyp<c-v>$r-A

" Set Level 3 Heading Underline
nnoremap <F7> yyp<c-v>$r~
inoremap <F7> <Esc>yyp<c-v>$r~A

" Set Level 4 Heading Underline
nnoremap <F8> yyp<c-v>$r"
inoremap <F8> <Esc>yyp<c-v>$r"A

" For autodate plugin:
let b:autodate_format='%Y%m%d-%H%M'

" All these abbreviations are replaced by the ultisnippets
" Org mode timestamp
"iabbrev orgts <c-r>=strftime("<%Y-%m-%d %H:%M>")<CR>
"iabbrev <expr> dts strftime("%Y-%m-%d %H:%M:%S (%A)")
"iabbrev <expr> dts strftime("%c")
"iabbrev <expr> shortheader '/* <cr><C-R>=expand("%:t")<CR><cr><c-r>=strftime("%c")<CR><cr>Jeffrey Gipson (JAG)<CR>/<CR>'
"iabbrev longheader <Esc>:0<CR>:r ~/.vim/longheader<CR>:0<CR>dd}i#    <c-r>=strftime("%m/%d/%Y")<CR> jag<Esc><Esc>?<NAME><CR>cW<c-r>=expand("%:t")<CR><Esc>/Description<CR>C
"iabbrev longheader <Esc>:0<CR>:r ~/.vim/longheader<CR>:0<CR>dd2}i#    <c-r>=strftime("%m/%d/%Y")<CR> jag<Esc><Esc>?<NAME><CR>cW<c-r>=expand("%:t")<CR><Esc>/Description<CR>hC
"iabbrev readmeheader <Esc>gg0:r ! echo "$(basename $PWD) README"yyp<c-v>$r-kkddj0
"iabbrev lorem <Esc>:r ~/.vim/lorem.txt<CR>i

" insert a bash function with 
"autocmd filetype sh iabbrev function() <esc>ddo#<cr># NAMEME () :<cr>#  desc<cr>NAMEME ()<cr>{<cr><tab><cr>}<cr><esc>V6k:s/NAMEME//g<left><left>

" Fix God-awful pepto-pink completion color
highlight Pmenu ctermbg=238 gui=bold

" Add toggle for spell check
nnoremap <f12> :call ToggleSpelling()<cr>
inoremap <f12> <esc>:call ToggleSpelling()<cr>i

" Toggles spelling and whitespace error detection
function! ToggleSpelling()
  if &l:spell
    setl nospell
    setl nohlsearch
    match
  else
    setl spell
    if match(&formatoptions, "w")
      highlight WSError guibg=red ctermbg=4
      match WSError /\s\+$/
    endif
  endif
endfunction

" Append modeline after last line in buffer.
" Use substitute() instead of printf() to handle '%%s' modeline in LaTeX
" files.
function! AppendModeline()
  let l:modeline = printf(" vim: set ts=%d sw=%d tw=%d %set :",
        \ &tabstop, &shiftwidth, &textwidth, &expandtab ? '' : 'no')
  let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
  call append(line("$"), l:modeline)
endfunction
nnoremap <silent> <Leader>ml :call AppendModeline()<CR>

" gundo activation
nnoremap <F4> :GundoToggle<CR>

hi StatusLine ctermbg=230 ctermfg=107 guifg=#526639
set statusline=%m\ %f\ %y%r%q%w%=(%l/%L):%c
set laststatus=2

function! InsertStatuslineColor(mode)
  if a:mode == 'i'
    hi statusline guibg=yellow
  elseif a:mode == 'r'
    hi statusline guibg=red
  else
    hi statusline guibg=orange
  endif
endfunction

au InsertEnter * call InsertStatuslineColor(v:insertmode)
au InsertChange * call InsertStatuslineColor(v:insertmode)
au InsertLeave * hi statusline guibg=green

" default the statusline to green when entering Vim
hi statusline guibg=green
