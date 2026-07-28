-- ========== Neovim 快捷键映射 ==========
-- 从 ~/.vimrc 转换为 Lua 格式

local map = vim.keymap.set
vim.g.mapleader = " "
vim.g.maplocalleader = ","
-- which-key v3 通过 triggers 配置自动拦截 <leader>，无需手动映射 Space
-- 让 Ctrl+[ 在常用模式下都等价于 Esc
map({ "n", "v", "i" }, "<C-[>", "<Esc>", { silent = true, desc = "退出到普通模式" })

-- ========== 基础操作 ==========
-- 快速保存
map('n', '<Leader>w', '<cmd>w<cr>', { desc = "保存文件" })

-- 快速退出
map('n', '<Leader>q', '<cmd>q<cr>', { desc = "退出" })

-- 手动唤起 which-key（兜底）
-- 注意：不要在这里直接调用 wk.show()，避免递归触发
map('n', '<Leader>?', '<cmd>WhichKey <leader><CR>', { desc = "显示快捷键帮助" })

-- ========== 搜索相关 ==========
-- 取消搜索高亮已整合到 multicursor.nvim 的 <Esc> 智能处理中

-- ========== 快速移动 ==========
-- 软换行时按视觉行移动
map('n', 'j', 'gj', { desc = "按视觉行向下移动" })
map('n', 'k', 'gk', { desc = "按视觉行向上移动" })

-- J/K 快速移动 5 行
map('n', 'J', '5j', { desc = "向下移动 5 行" })
map('n', 'K', '5k', { desc = "向上移动 5 行" })
map('v', 'J', '5j', { desc = "向下移动 5 行" })
map('v', 'K', '5k', { desc = "向上移动 5 行" })

-- 合并行功能改用 空格+j
map('n', '<Leader>j', 'J', { desc = "合并当前行和下一行" })

-- 快速移动到行首/行尾
map('n', 'H', '^', { desc = "移动到行首（非空白字符）" })
map('n', 'L', '$', { desc = "移动到行尾" })

-- ========== 窗口导航 ==========
-- Alt-hjkl 由 vim-tmux-navigator 接管，实现 Neovim/tmux 无缝移动。

-- ========== 调整分屏大小 ==========
local resize_step = 5
map('n', '<Leader>=', '<C-w>=', { desc = "均分所有窗口" })
map('n', '<Leader>-', '<C-w>-', { desc = "减小窗口高度" })
map('n', '<Leader>+', '<C-w>+', { desc = "增大窗口高度" })
map('n', '<A-H>', '<cmd>vertical resize -' .. resize_step .. '<cr>', { desc = "减小窗口宽度" })
map('n', '<A-L>', '<cmd>vertical resize +' .. resize_step .. '<cr>', { desc = "增大窗口宽度" })
map('n', '<A-J>', '<cmd>resize -' .. resize_step .. '<cr>', { desc = "减小窗口高度" })
map('n', '<A-K>', '<cmd>resize +' .. resize_step .. '<cr>', { desc = "增大窗口高度" })

-- ========== 复制增强 ==========
-- Y 复制到行尾（更符合 D/C 的逻辑）
map('n', 'Y', 'y$', { desc = "复制到行尾" })

-- ========== 可视模式 ==========
-- 在可视模式下保持选中状态缩进
map('v', '<', '<gv', { desc = "左缩进并保持选中" })
map('v', '>', '>gv', { desc = "右缩进并保持选中" })
-- 替换选区时不污染默认寄存器
map('v', 'p', '"_dP', { desc = "替换选区并保留寄存器" })
-- Alt-j/k 在插入/可视模式下移动行；普通模式留给 vim-tmux-navigator。
map('i', '<A-j>', '<Esc>:m .+1<CR>==gi', { desc = "向下移动当前行" })
map('i', '<A-k>', '<Esc>:m .-2<CR>==gi', { desc = "向上移动当前行" })
map('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = "向下移动选中行" })
map('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = "向上移动选中行" })

-- ========== LSP 诊断 ==========
-- 查看当前行的详细报错信息（浮窗）
map('n', '<Leader>dd', vim.diagnostic.open_float, { desc = "查看报错详情" })
-- 跳转到上/下一个报错（Neovim 0.11+ 推荐 diagnostic.jump）
map('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, { desc = "上一个报错" })
map('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, { desc = "下一个报错" })
-- 列出当前文件所有报错
map('n', '<Leader>dl', vim.diagnostic.setloclist, { desc = "报错列表" })

-- ========== 缓冲区管理 ==========
-- 用 Snacks.bufdelete 而非原生 :bdelete，关闭缓冲区时保持窗口布局不变
map('n', '<Leader>bd', function() Snacks.bufdelete() end, { desc = "关闭当前缓冲区" })
map('n', ']b', '<cmd>bnext<cr>', { desc = "下一个缓冲区" })
map('n', '[b', '<cmd>bprevious<cr>', { desc = "上一个缓冲区" })

-- ========== 终端 ==========
-- 终端管理已由 snacks.terminal 接管（Ctrl-\ 打开浮动终端）
-- 终端内的 Esc 快捷键由终端自行管理
