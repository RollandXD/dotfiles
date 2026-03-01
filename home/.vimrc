" ========== 插件管理 ==========
call plug#begin('~/.vim/plugged')

" 丝滑滚动插件
Plug 'yuttie/comfortable-motion.vim'

call plug#end()

" ========== comfortable-motion 配置 ==========
" 滚动速度和摩擦力
let g:comfortable_motion_friction = 50.0      " 摩擦力（越小停得越快）
let g:comfortable_motion_air_drag = 2.0       " 空气阻力（越大减速越快）

" 如果想让滚动更快，可以调整这个
let g:comfortable_motion_scroll_down_key = "j"
let g:comfortable_motion_scroll_up_key = "k"

" ========== 禁用蜂鸣声 ========
set belloff=all

" ========== 基础设置 ==========
" 开启语法高亮
syntax on

" 显示行号
set number
" 显示相对行号（跳转神器，配合 10j, 5k 使用）
set relativenumber

" 高亮当前行
set cursorline

" 显示匹配的括号
set showmatch

" 显示当前模式
set showmode

" 显示输入的命令
set showcmd

" 启用文件类型检测
filetype plugin indent on

" ========== 搜索设置 ==========
" 搜索时忽略大小写，除非包含大写字母
set ignorecase
set smartcase

" 搜索时实时高亮
set incsearch
set hlsearch

" 取消搜索高亮
nnoremap <C-n> :noh<CR>

" 搜索到底部时循环到顶部
set wrapscan

" ========== 编辑设置 ==========
" 缩进设置（4 空格）
set tabstop=4
set shiftwidth=4
set expandtab
set smarttab
set autoindent
set smartindent

" 允许 Backspace 删除一切
set backspace=indent,eol,start

" 自动换行
set wrap
set linebreak

" 保留撤销历史
set undofile
set undodir=~/.vim/undodir

" ========== 文件设置 ==========
" 自动读取外部修改
set autoread

" 文件编码
set encoding=utf-8
set fileencodings=utf-8,gbk,gb2312,big5

" 永远不要生成 swap 备份文件（看个人喜好）
set nobackup
set noswapfile

" ========== 界面设置 ==========
" 命令行补全增强
set wildmenu
set wildmode=longest:full,full

" 始终显示状态栏
set laststatus=2

" 滚动时保持上下留 5 行
set scrolloff=5

" 分屏时默认在右边和下边
set splitright
set splitbelow

" ========== 剪贴板设置 ==========
" 启用系统剪贴板共享（需要 Vim 支持 +clipboard）
" Linux/Mac 用这个
" set clipboard=unnamedplus
" Windows 用这个
set clipboard=unnamed

" ========== 快捷键映射 ==========
" 将 Leader 键设为空格
let mapleader = " "

" 快速保存
nnoremap <Leader>w :w<CR>

" 快速退出
nnoremap <Leader>q :q<CR>

" J/K 快速移动(normal)
nnoremap J 5j
nnoremap K 5k

" 合并行功能改用 空格+j
nnoremap <Leader>j J

" 快速移动到行首/行尾
nnoremap H ^
nnoremap L $

" 在分屏间快速移动
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" 调整分屏大小
nnoremap <Leader>= <C-w>=
nnoremap <Leader>- <C-w>-
nnoremap <Leader>+ <C-w>+

" Y 复制到行尾（更符合 D/C 的逻辑）
nnoremap Y y$

" 在可视模式下保持选中状态缩进
vnoremap < <gv
vnoremap > >gv

" 移动选中的行
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" ========== 颜色主题 ==========
" 如果终端支持 256 色
set t_Co=256

" 使用暗色背景
set background=dark
