
" ======= 基础设置 ========
" 显示
colorscheme gruvbox " 设定 gruvbox 主题
set background=dark " 设定背景颜色
set t_Co=256 " 启用256色

" 突出显示行列
"set cursorline " 突出显示当前行
"set cursorcolumn " 突出显示当前列

" 行号
set number " 启用绝对行号
set relativenumber " 启用相对行号

" 状态栏
set ruler " 显示光标位置
set laststatus=2 " 总是显示状态栏
set showcmd " 命令模式下，在底部显示，当前键入的指令
set showmode " 在底部显示，当前处于命令模式还是插入模式
set statusline=\ %<%F[%1*%M%*%n%R%H]%=\ %y\ %0(%{&fileformat}\ %{&encoding}\ %c:%l/%L%)\ " 设置在状态行显示的信息

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
set paste " 设置粘贴模式
set autoread " 当文件在外部被修改时，自动更新该文件
set autochdir " 自动切换当前目录为当前文件所在的目录
"set spell spelllang=en_us " 英语单词拼写检查

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


" ======= vim-plug 插件管理 =======
call plug#begin('~/.config/nvim/plug')
Plug 'morhetz/gruvbox'
call plug#end()

