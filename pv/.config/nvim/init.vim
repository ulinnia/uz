" 使用 zsh，因为 vim 不支持 fish
set shell=/bin/zsh

" ======= 键位设定 =======

" 前缀键
let mapleader = "\<space>"

" 命令，强制，退出，保存，宏
noremap ; :
noremap <leader>/ :!<left>
noremap q :q<cr>
noremap w :w<cr>
noremap Q q

" ======= 移动 =======

" 移动光标
noremap <silent> H 0
noremap <silent> L $
noremap <silent> J 5j
noremap <silent> K 5k
noremap f w
noremap F 5w
noremap B 5b

" 不移动光标移动
noremap <c-k> 5<c-y>
noremap <c-j> 5<c-e>

" 分屏移动
noremap <leader>h <C-w>h
noremap <leader>j <C-w>j
noremap <leader>k <C-w>k
noremap <leader>l <C-w>l

" 命令模式移动
cnoremap <c-a> <home>
cnoremap <c-e> <end>
cnoremap <c-p> <up>
cnoremap <c-n> <down>
cnoremap <c-b> <left>
cnoremap <c-f> <right>
cnoremap <m-b> <s-left>
cnoremap <m-w> <s-right>

" ======= 分页分屏 =======

" 分页
noremap tu :tabe<CR>
" 分页移动
noremap th :-tabnext<CR>
noremap tl :+tabnext<CR>
" 分页排列
noremap tmh :-tabmove<CR>
noremap tml :+tabmove<CR>

" 分屏
noremap sh :set nosplitright<CR>:vsplit<CR>:set splitright<CR>
noremap sj :set splitbelow<CR>:split<CR>
noremap sk :set nosplitbelow<CR>:split<CR>:set splitbelow<CR>
noremap sl :set splitright<CR>:vsplit<CR>
" 分屏调整大小
noremap <leader><up> :res +5<CR>
noremap <leader><down> :res -5<CR>
noremap <leader><left> :vertical resize-5<CR>
noremap <leader><right> :vertical resize+5<CR>
" 分屏排列
noremap sg <C-w>t<C-w>K
noremap sv <C-w>t<C-w>H
" 分屏旋转
noremap srg <C-w>b<C-w>K
noremap srv <C-w>b<C-w>H

" ======= 其他 =======

" 替换
noremap <leader>s :%s//gc<left><left><left>

" 占位符 <++>
noremap <leader><leader> <Esc>/<++><CR>:nohlsearch<CR>c4l

" ======= 行为设定 =======

" 显示优化
set mouse=a " 启用鼠标滚轮和右键
set wrap linebreak " 自动折行，不在单词内部折行
set showmatch matchtime=2 " 插入括号时，短暂地跳转到匹配的对应括号
set scrolloff=5 " 垂直滚动时，光标距离顶部/底部的位置
set list listchars=tab:>-,trail:~,nbsp:+,extends:>,precedes:< " 显示隐藏字符
set number relativenumber  " 显示行号
" 关闭行号
noremap <f6> :set nu! rnu!<cr>

" 缩进、退格
set expandtab       " tab键转空格
set tabstop=4       " tab 宽度
set shiftwidth=4    " 自动缩进字元数
set softtabstop=4   " 使得按退格键时可以一次删掉 4 个空格
set autoindent      " 继承前一行的缩进方式，适用于多行注释
set backspace=indent,eol,start  " 退格键可删除回车符

" 折叠
set foldenable          " zM开始折叠，zR关闭折叠
set foldmethod=indent   " 设置缩进折叠
set foldcolumn=0        " 设置折叠区域的宽度
set foldlevel=1         " 设置折叠层数

" 状态栏
set laststatus=2    " 总是显示状态栏
set showcmd         " 显示当前键入的指令
set showmode        " 显示当前的模式

" 状态栏格式
set statusline=
set statusline+=%1*\[%n]                    " 当前 buffer
set statusline+=%2*\ %<%F                   " 文件路径
set statusline+=%3*\ %m%r%h%w               " 文件特殊属性
set statusline+=%4*\ %=\ (%p%%)\ %c:%l/%L   " 当前光标位置
set statusline+=%5*\ %y                     " 文件类别
set statusline+=%6*\ %{&fileencoding}       " 文件编码
set statusline+=%7*\ %{&ff}                 " dos/unix

" 搜索
set history=1000    " 历史指令数
set hlsearch        " 搜索时高亮显示被找到的文本
" 关闭搜索高亮
noremap <leader><cr> :nohlsearch<cr>
set incsearch       " 实时搜索
set nowrapscan      " 禁止在搜索到文件两端时重新搜索
set ignorecase smartcase " 搜索时智能忽略大小写

" 指令
set magic       " 设置魔术
set wildmenu    " 命令模式下，底部操作指令按下 Tab 键自动补全
set wildmode=longest:list,full " 第一次按下 Tab，会显示所有匹配的操作指令的清单；第二次按下 Tab，会依次选择各个指令

" 文件类型
syntax enable               " 打开语法高亮
filetype plugin indent on   " 打开文件类型检测

" 设置文件编码
set encoding=utf-8      " 内部编码
set termencoding=utf-8  " 显示编码
set fileencoding=utf-8  " 新文件编码
set fileencodings=utf-8,utf-16 " 解码猜测顺序

" 设置语言编码
set langmenu=zh_CN.UTF-8
set helplang=cn " 显示中文帮助

" 编辑
set autoread    " 当文件在外部被修改时，自动更新该文件
set autochdir   " 自动切换当前目录为当前文件所在的目录

" 备份、交换文件
set autowrite   " 自动保存
set undofile    " 保留撤销历史
set nobackup    " 不创建备份文件
set noswapfile  " 不创建交换文件

" 备份文件、交换文件、操作历史文件的保存位置
set backupdir=~/.config/nvim/.backup//
set directory=~/.config/nvim/.swp//
set undodir=~/.config/nvim/.undo//

" 错误响铃
set noerrorbells    " 关闭错误信息响铃
set novisualbell    " 关闭使用可视响铃代替呼叫

" ======= 函数 =======

" 编译运行快捷键
map <leader>r :call CompileRunGcc()<CR>
func! CompileRunGcc()
    exec "w"
    if &filetype == 'c'
        exec "!g++ % -o %<"
        :bel sp | term time ./%<
    elseif &filetype == 'cpp'
        exec "!g++ % -o %<"
        :bel sp | term time ./%<
    elseif &filetype == 'fish'
        :bel sp | term time fish %
    elseif &filetype == 'go'
        :bel sp | term go run .
    elseif &filetype == 'html'
        exec "!firefox % &"
    elseif &filetype == 'java'
        :bel sp | term javac % && time java %<
    elseif &filetype == 'markdown'
        exec "InstantMarkdownPreview"
    elseif &filetype == 'python'
        :bel sp | term python %
    elseif &filetype == 'rust'
        :bel sp | term cargo run
    elseif &filetype == 'sh'
        :bel sp | term time bash %
    endif
endfunc

" ======= vim-plug 插件管理 =======

call plug#begin('~/.config/nvim/plug')

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'dag/vim-fish'
Plug 'jiangmiao/auto-pairs'
Plug 'Yggdroot/indentLine'
Plug 'vim-airline/vim-airline'
Plug 'scrooloose/nerdcommenter'
Plug 'liuchengxu/vista.vim'

call plug#end()

" ======= coc =======

" 自动下载 coc 插件
let g:coc_global_extensions = [
  \ 'coc-clangd',
  \ 'coc-fish',
  \ 'coc-highlight',
  \ 'coc-pyright',
  \ 'coc-rust-analyzer',
  \ 'coc-sh',
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
nnoremap <silent> gf :call <SID>show_documentation()<CR>

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

" ======= defx =======

call defx#custom#option('_', {
      \ 'winwidth': 30,
      \ 'split': 'vertical',
      \ 'direction': 'topleft',
      \ 'show_ignored_files': 0,
      \ 'buffer_name': '',
      \ 'toggle': 1,
      \ 'resume': 1
      \ })

autocmd FileType defx call s:defx_mappings()

function! s:defx_mappings() abort
  nnoremap <silent><buffer><expr> l     <SID>defx_toggle_tree()                    " 打开或者关闭文件夹，文件
  nnoremap <silent><buffer><expr> .     defx#do_action('toggle_ignored_files')     " 显示隐藏文件
  nnoremap <silent><buffer><expr> <C-r>  defx#do_action('redraw')
endfunction

function! s:defx_toggle_tree() abort
    " Open current file, or toggle directory expand/collapse
    if defx#is_directory()
        return defx#do_action('open_or_close_tree')
    endif
    return defx#do_action('multi', ['drop'])
endfunction

nmap <silent> <f3> :Defx<cr>

" ======= indentline =======

let g:indent_guides_guide_size = 1 " 指定对齐线的尺寸
let g:indent_guides_start_level = 2 " 从第二层开始可视化显示缩进
nmap <F7> :IndentLinesToggle<CR>

" ======= vista =======

nnoremap <silent><nowait> <f8> :<c-u>Vista!!<cr>

