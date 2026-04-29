-- ========== Neovim 主配置文件 ==========
-- 从 Vim 迁移到 Neovim 的渐进式配置
-- 迁移日期: 2026-02-16

-- 加载基础选项设置
require("config.options")

-- 加载快捷键映射
require("config.keymaps")

-- 加载插件管理器（lazy.nvim）
require("config.lazy")

-- 加载自动命令
require("config.autocmds")

-- 加载 C++ 开发辅助命令
require("config.cpp-tools")

-- 会话管理由 persistence.nvim 插件自动处理

-- 欢迎提示已由 snacks dashboard 取代
