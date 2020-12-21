
" ======= 基础设置 ========
" 前缀键
let mapleader = "\<space>"
" 显示
set background=dark " 设定背景颜色
"set termguicolors " 开启真彩色

" 行号
set number " 启用绝对行号
set relativenumber " 启用相对行号

" 状态栏
set ruler " 显示光标位置
set laststatus=2 " 总是显示状态栏
set showcmd " 命令模式下，在底部显示，当前键入的指令
set showmode " 在底部显示，当前处于命令模式还是插入模式
set statusline=\ %<%F[%1*%M%*%n%R%H]%=\ %y\ %0(%{&fileformat}\ %{&fileencoding}\ %c:%l/%L%)\ " 设置在状态行显示的信息

" 折行
set wrap " 自动折行
set textwidth=80 " 设置行宽
set linebreak " 不在单词内部折行
"set wrapmargin=2 " 指定折行处与编辑窗口的右边缘之间空出的字符数

" 光标位置
set scrolloff=5 " 垂直滚动时，光标距离顶部/底部的位置（单位：行）
set sidescrolloff=15 " 水平滚动时，光标距离行首或行尾的位置（单位：字符）。该配置在不折行时比较有用。

" 括号
set showmatch " 插入括号时，短暂地跳转到匹配的对应括号
set matchtime=2 " 短暂跳转到匹配括号的时间

" 隐藏字符
set list " 显示隐藏字符
set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:< " 定义隐藏字符显示
noremap <F6> :set nolist " 关闭显示隐藏字符快捷键
noremap <F7> :set list " 开启显示隐藏字符快捷键

" 缩进、退格
set expandtab " tab键转空格
set tabstop=4 " tab 宽度
set shiftwidth=4 " 自动缩进字元数
set softtabstop=4 " 使得按退格键时可以一次删掉 4 个空格
set autoindent " 继承前一行的缩进方式，适用于多行注释
set backspace=indent,eol,start " 不设定在插入状态无法用退格键和 Delete 键删除回车符

" 折叠
set foldenable " 开始折叠
set foldmethod=syntax " 设置语法折叠
set foldcolumn=0 " 设置折叠区域的宽度
setlocal foldlevel=1 " 设置折叠层数为
" set foldclose=all " 设置为自动关闭折叠

" 编辑
set autoread " 当文件在外部被修改时，自动更新该文件
set autochdir " 自动切换当前目录为当前文件所在的目录

" 搜索
set history=1000 " 历史指令数
set hlsearch " 搜索时高亮显示被找到的文本
set incsearch " 实时搜索
set nowrapscan " 禁止在搜索到文件两端时重新搜索
set ignorecase smartcase " 搜索时忽略大小写，但在有一个或以上大写字母时仍保持对大小写敏感

" 指令
set magic " 设置魔术
set nocompatible " 不与 Vi 兼容（采用 Vim 自己的操作命令）
set wildmenu " 命令模式下，底部操作指令按下 Tab 键自动补全
set wildmode=longest:list,full " 第一次按下 Tab，会显示所有匹配的操作指令的清单；第二次按下 Tab，会依次选择各个指令

" 文件类型
syntax on " 打开语法高亮。自动识别代码，使用多种颜色显示
filetype plugin indent on " 打开文件类型检测

" 错误响铃
set noerrorbells " 关闭错误信息响铃
set novisualbell " 关闭使用可视响铃代替呼叫
set t_vb= " 置空错误铃声的终端代码

" 备份、交换文件
set autowrite " 自动保存
set nobackup " 不创建备份文件
set noswapfile " 不创建交换文件
set undofile " 保留撤销历史

" 启用鼠标
set mouse=a " 启用鼠标滚轮和右键
"set selection=exclusive
"set selectmode=mouse,key

" 设置文件编码
set encoding=utf-8 " 内部编码
set termencoding=utf-8 " 显示编码
set fileencoding=utf-8 " 新文件编码
set fileencodings=utf-8,utf-16 " 解码猜测顺序

" 设置语言编码
set langmenu=zh_CN.UTF-8
set helplang=cn " 显示中文帮助

" 备份文件、交换文件、操作历史文件的保存位置
set backupdir=~/.config/nvim/.backup//
set directory=~/.config/nvim/.swp//
set undodir=~/.config/nvim/.undo//

" 编译文件快捷键
map r :call CompileRunGcc()<CR>
func! CompileRunGcc()
  exec "w"
  if &filetype == 'c'
    if !isdirectory('vx')
      exec "!mkdir vx"
    endif
    exec "!g++ % -o vx/%<"
    exec "!time ./vx/%<"
  elseif &filetype == 'cpp'
    if !isdirectory('vx')
      exec "!mkdir vx"
    endif
    exec "!g++ % -o vx/%<"
    exec "!time ./vx/%<"
  elseif &filetype == 'java'
    if !isdirectory('vx')
      exec "!mkdir vx"
    endif
    exec "!javac vx/%"
    exec "!time java vx/%<"
  elseif &filetype == 'sh'
    :!time bash %
  elseif &filetype == 'python'
    silent! exec "!clear"
    exec "!time python3 %"
  elseif &filetype == 'html'
    exec "!firefox % &"
  elseif &filetype == 'markdown'
    exec "MarkdownPreview"
  elseif &filetype == 'vimwiki'
    exec "MarkdownPreview"
  endif
endfunc


" ======= vim-plug 插件管理 =======
call plug#begin('~/.config/nvim/plug')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'preservim/nerdtree'
Plug 'jiangmiao/auto-pairs'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'Yggdroot/indentLine'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes' "airline 的主题
Plug 'scrooloose/nerdcommenter'
Plug 'luochen1990/rainbow'
call plug#end()

" ======= cocnvim =======
" 自动下载 coc 插件
let g:coc_global_extensions = [
  \ 'coc-clangd',
  \ 'coc-vimlsp']
set hidden
set updatetime=100
set shortmess+=c

" tab 补全
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" 调出自动补全
inoremap <silent><expr> <c-space> coc#refresh()

" 选择补全后enter不换行
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" 上下查找报错
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" 查看函数调用
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" 显示文档
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" 同名高亮
autocmd CursorHold * silent call CocActionAsync('highlight')

" 变量重命名
nmap <leader>rn <Plug>(coc-rename)

" 格式化代码
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" 默认行为
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" ======= autopair =======
au Filetype FILETYPE let b:AutoPairs = {"(": ")"}
au FileType php      let b:AutoPairs = AutoPairsDefine({'<?' : '?>', '<?php': '?>'})

" ======= nerdtree =======
" autocmd vimenter * NERDTree  "自动开启Nerdtree
let g:NERDTreeWinSize = 25 "设定 NERDTree 视窗大小
let NERDTreeShowBookmarks=1  " 开启Nerdtree时自动显示Bookmarks
"打开vim时如果没有文件自动打开NERDTree
" autocmd vimenter * if !argc()|NERDTree|endif
"当NERDTree为剩下的唯一窗口时自动关闭
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" 设置树的显示图标
let g:NERDTreeDirArrowExpandable = '+'
let g:NERDTreeDirArrowCollapsible = '-'
let NERDTreeIgnore = ['\.pyc$']  " 过滤所有.pyc文件不显示
let g:NERDTreeShowLineNumbers=0 " 是否显示行号
let g:NERDTreeHidden=0     "不显示隐藏文件
""Making it prettier
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
nnoremap <F3> :NERDTreeToggle<CR> " 开启/关闭nerdtree快捷键

" ======= indentline =======
let g:indent_guides_guide_size = 1 " 指定对齐线的尺寸
let g:indent_guides_start_level = 2 " 从第二层开始可视化显示缩进

" ======= airline =======
" 设置状态栏
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#buffer_nr_show = 0
let g:airline#extensions#tabline#formatter = 'default'
let g:airline_theme = 'gruvbox'  " 主题
let g:airline#extensions#keymap#enabled = 1
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline#extensions#tabline#buffer_idx_format = {
       \ '0': '0 ',
       \ '1': '1 ',
       \ '2': '2 ',
       \ '3': '3 ',
       \ '4': '4 ',
       \ '5': '5 ',
       \ '6': '6 ',
       \ '7': '7 ',
       \ '8': '8 ',
       \ '9': '9 '
       \}
" 设置切换tab的快捷键 <\> + <i> 切换到第i个 tab
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9
" 设置切换tab的快捷键 <\> + <-> 切换到前一个 tab
nmap <leader>- <Plug>AirlineSelectPrevTab
" 设置切换tab的快捷键 <\> + <+> 切换到后一个 tab
nmap <leader>+ <Plug>AirlineSelectNextTab
" 设置切换tab的快捷键 <\> + <q> 退出当前的 tab
nmap <leader>q :bp<cr>:bd #<cr>

" ======= nerdcommenter =======
"add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" python 自动的会多加一个空格
au FileType python let g:NERDSpaceDelims = 0

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

" Set a language to use its alternate delimiters by default
let g:NERDAltDelims_java = 1

" Add your own custom formats or override the defaults
" let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" Enable NERDCommenterToggle to check all selected lines is commented or not
let g:NERDToggleCheckAllLines = 1

" ======= rainbow =======
let g:rainbow_active = 1
let g:rainbow_conf = {
\   'guifgs': ['darkorange3', 'seagreen3', 'royalblue3', 'firebrick'],
\   'ctermfgs': ['lightyellow', 'lightcyan','lightblue', 'lightmagenta'],
\   'operators': '_,_',
\   'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
\   'separately': {
\       '*': {},
\       'tex': {
\           'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
\       },
\       'lisp': {
\           'guifgs': ['darkorange3', 'seagreen3', 'royalblue3', 'firebrick'],
\       },
\       'vim': {
\           'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold', 'start=/(/ end=/)/ containedin=vimFuncBody', 'start=/\[/ end=/\]/ containedin=vimFuncBody', 'start=/{/ end=/}/ fold containedin=vimFuncBody'],
\       },
\       'html': {
\           'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
\       },
\       'css': 0,
\   }
\}
