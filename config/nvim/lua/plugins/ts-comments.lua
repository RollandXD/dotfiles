-- ========== ts-comments.nvim - 按 Treesitter 语境修正 commentstring ==========
-- 注释本身用 Neovim 0.10+ 原生的 gc / gcc / gc 文本对象；本插件只负责让
-- Markdown 代码块、Vue/HTML 内嵌脚本等混合语言里的 gc 用对注释符号。

return {
  "folke/ts-comments.nvim",
  event = "VeryLazy",
  opts = {},
}
