-- ========== inc-rename.nvim - 行内重命名预览 ==========
-- 原地预览 LSP 重命名效果
-- 快捷键 grn 由 lspconfig.lua 统一管理（LSP 就绪时才可用）

return {
  "smjonas/inc-rename.nvim",
  lazy = true, -- 由 lspconfig 中的 require 触发加载
  opts = {},
}
