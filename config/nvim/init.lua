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

-- ========== 欢迎提示 ==========
-- 首次启动时显示提示信息
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    -- 只在没有打开文件时显示
    if vim.fn.argc() == 0 then
      print("🎉 Neovim 配置加载成功！按 <Space> 可查看快捷键提示")
    end
  end,
})
