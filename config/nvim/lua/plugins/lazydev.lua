-- ========== lazydev.nvim - Neovim Lua 开发支持 ==========
-- 按需把当前配置引用的插件类型加入 LuaLS workspace，并为 blink.cmp 提供模块补全。

return {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  },
}
