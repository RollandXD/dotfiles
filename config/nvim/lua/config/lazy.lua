-- ========== lazy.nvim 插件管理器引导 ==========

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- 自动安装 lazy.nvim
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  print("正在安装 lazy.nvim 插件管理器...")
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  print("lazy.nvim 安装完成！")
end

-- 将 lazy.nvim 添加到运行时路径
vim.opt.rtp:prepend(lazypath)

-- 在 Lazy UI 内把 hover 键从 K 改为 gK，避免覆盖你的 K=5k 习惯
pcall(function()
  local view_config = require("lazy.view.config")
  view_config.keys.hover = "gK"
end)

-- 加载插件（从 ~/.config/nvim/lua/plugins/ 目录）
require("lazy").setup("plugins", {
  -- 自动检查插件更新
  checker = {
    enabled = true,
    notify = false, -- 不显示通知
  },
  -- UI 设置
  ui = {
    border = "rounded",
    -- WSL 下显式指定打开链接的命令，避免 fallback 到 macOS 的 open
    browser = vim.fn.expand("~/.config/nvim/scripts/open-uri.sh"),
  },
  -- 性能优化
  performance = {
    rtp = {
      -- 禁用一些不需要的内置插件
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
