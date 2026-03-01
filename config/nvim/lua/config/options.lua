-- ========== Neovim 基础选项设置 ==========
-- 从 ~/.vimrc 转换为 Lua 格式

local opt = vim.opt

-- ========== 基础设置 ==========
-- 开启语法高亮（Neovim 默认已开启）
vim.cmd('syntax on')

-- 显示行号
opt.number = true
-- 显示相对行号（跳转神器，配合 10j, 5k 使用）
opt.relativenumber = true

-- 高亮当前行
opt.cursorline = true

-- 显示匹配的括号
opt.showmatch = true

-- 显示当前模式
opt.showmode = true

-- 显示输入的命令
opt.showcmd = true

-- 启用文件类型检测（Neovim 默认已开启）
vim.cmd('filetype plugin indent on')

-- ========== 搜索设置 ==========
-- 搜索时忽略大小写，除非包含大写字母
opt.ignorecase = true
opt.smartcase = true

-- 搜索时实时高亮
opt.incsearch = true
opt.hlsearch = true

-- 搜索到底部时循环到顶部
opt.wrapscan = true

-- ========== 编辑设置 ==========
-- 缩进设置（4 空格）
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smarttab = true
opt.autoindent = true
opt.smartindent = true

-- 允许 Backspace 删除一切
opt.backspace = "indent,eol,start"

-- 自动换行
opt.wrap = true
opt.linebreak = true

-- 保留撤销历史
opt.undofile = true
opt.undodir = vim.fn.expand("~/.vim/undodir")

-- ========== 文件设置 ==========
-- 自动读取外部修改
opt.autoread = true

-- 文件编码
opt.encoding = "utf-8"
opt.fileencodings = "utf-8,gbk,gb2312,big5"

-- 永远不要生成 swap 备份文件
opt.backup = false
opt.swapfile = false

-- ========== 界面设置 ==========
-- 命令行补全增强
opt.wildmenu = true
opt.wildmode = "longest:full,full"

-- 始终显示状态栏
opt.laststatus = 2

-- 滚动时保持上下留 5 行
opt.scrolloff = 5

-- 分屏时默认在右边和下边
opt.splitright = true
opt.splitbelow = true

-- ========== 剪贴板设置 ==========
-- WSL2 环境使用 unnamed（与 Windows 剪切板共享）
opt.clipboard = "unnamed"

-- ========== 禁用蜂鸣声 ==========
opt.belloff = "all"

-- ========== 颜色设置 ==========
-- 启用真彩色支持
opt.termguicolors = true

-- 使用暗色背景
opt.background = "dark"
