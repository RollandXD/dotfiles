-- ========== Neovim 基础选项设置 ==========
-- 只写与 Neovim 默认值不同的项；nvim 已默认开启的（hlsearch、incsearch、autoread、
-- smarttab、wildmenu、belloff=all、termguicolors 等）不再重复声明。

local opt = vim.opt

-- ========== 行号与光标 ==========
opt.number = true
opt.relativenumber = true -- 相对行号（配合 10j、5k 跳转）
opt.cursorline = true
opt.showmatch = true
opt.showmode = false -- lualine 已显示中文模式名

-- ========== 搜索 ==========
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split" -- :s 替换时在分屏中实时预览所有改动

-- ========== 缩进（4 空格；具体缩进表达式由 treesitter 提供）==========
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

-- ========== 换行与滚动 ==========
opt.wrap = true
opt.linebreak = true
opt.smoothscroll = true -- 软换行长行按屏幕行平滑滚动
opt.scrolloff = 5
opt.sidescrolloff = 8
opt.jumpoptions = "view" -- 跳转返回时恢复原来的视图位置

-- ========== 编辑 ==========
opt.virtualedit = "block" -- 可视块模式允许越过行尾
opt.confirm = true -- 退出时有未保存修改则弹确认，而不是直接报错

-- ========== 文件 ==========
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"
opt.fileencodings = "utf-8,gbk,gb2312,big5"
opt.swapfile = false

-- ========== 界面 ==========
opt.wildmode = "longest:full,full"
opt.laststatus = 3 -- 全局状态栏（lualine 的 sync_laststatus 会动态调整）
opt.signcolumn = "yes" -- 始终显示符号列，避免诊断出现时行号跳动
opt.pumheight = 10
opt.splitright = true
opt.splitbelow = true
opt.fillchars = { foldopen = "▾", foldclose = "▸", fold = " ", foldsep = " ", eob = " " }

-- Alt/Meta 组合键识别等待时间（默认 50 已足够，显式写出防止被插件改动）
opt.ttimeoutlen = 50

-- ========== 折叠 ==========
-- 由 nvim-ufo 接管折叠；ufo 会把 foldmethod 切到 manual，需要较大的 foldlevel 保持默认展开
opt.foldcolumn = "1"
opt.foldlevel = 99
opt.foldlevelstart = 99

-- 会话保存内容：不保存 terminal，避免恢复时带出失效终端
opt.sessionoptions = { "buffers", "curdir", "folds", "help", "tabpages", "winsize", "localoptions" }

-- Wayland 系统剪贴板（需要 wl-clipboard）
opt.clipboard = "unnamedplus"

-- 光标静止 500ms 后触发 CursorHold（LSP 引用高亮依赖此值）
opt.updatetime = 500
