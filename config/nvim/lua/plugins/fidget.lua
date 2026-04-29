-- ========== fidget.nvim - LSP 进度提示 ==========
-- 右下角显示 LSP 加载/索引进度

return {
  "j-hui/fidget.nvim",
  event = "LspAttach",
  opts = {
    progress = {
      display = {
        done_ttl = 3, -- 完成后显示 3 秒
        progress_icon = { pattern = "dots", period = 1 },
      },
    },
    notification = {
      window = {
        winblend = 0, -- 不透明（配合暗色主题更清晰）
        border = "rounded",
      },
    },
  },
}
