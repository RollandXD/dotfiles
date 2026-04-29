-- ========== Neovim 基础选项设置 ==========
-- 从 ~/.vimrc 转换为 Lua 格式

local opt = vim.opt

-- ========== 基础设置 ==========
-- 语法高亮和文件类型检测（Neovim 默认已开启，无需手动设置）

-- 显示行号
opt.number = true
-- 显示相对行号（跳转神器，配合 10j, 5k 使用）
opt.relativenumber = true

-- 高亮当前行
opt.cursorline = true

-- 显示匹配的括号
opt.showmatch = true

-- 显示当前模式
opt.showmode = false  -- lualine 已显示中文模式名，无需原生显示

-- 显示输入的命令
opt.showcmd = true



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
opt.undodir = vim.fn.stdpath("state") .. "/undo"

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
opt.laststatus = 3  -- 全局状态栏（lualine 的 sync_laststatus 会动态调整）

-- 滚动时保持上下留 5 行
opt.scrolloff = 5

-- 始终显示符号列（避免诊断标记出现时行号跳动）
opt.signcolumn = "yes"

-- 补全菜单行为
opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 10  -- 补全菜单最大高度

-- 终端里更稳定地识别 Alt/Meta 组合键
opt.ttimeout = true
opt.ttimeoutlen = 50

-- 分屏时默认在右边和下边
opt.splitright = true
opt.splitbelow = true

-- ========== 折叠设置 ==========
-- 由 nvim-ufo 接管折叠（支持预览、更好的虚拟文本）
-- ufo 内部使用 treesitter/indent provider，无需手动设 foldmethod
opt.foldcolumn = "1"
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99

-- 会话保存内容：保留 buffer、目录、折叠、帮助页、标签页和窗口尺寸
-- 不保存 terminal，避免恢复时带出失效终端
opt.sessionoptions = {
    "buffers",
    "curdir",
    "folds",
    "help",
    "tabpages",
    "winsize",
    "localoptions",
}

-- ========== 剪贴板设置 ==========
-- Wayland 环境使用 unnamedplus（与系统剪切板共享，需要 wl-clipboard）
opt.clipboard = "unnamedplus"

-- ========== 禁用蜂鸣声 ==========
opt.belloff = "all"

-- 光标静止 500ms 后触发 CursorHold（LSP 高亮依赖此值）
opt.updatetime = 500

-- ========== 颜色设置 ==========
-- 启用真彩色支持
opt.termguicolors = true

-- 使用暗色背景
opt.background = "dark"
