-- ========== satellite.nvim - 装饰滚动条 ==========
-- 在侧边显示带装饰的滚动条，标记光标、搜索、诊断、Git 变更等

return {
  "lewis6991/satellite.nvim",
  event = "VeryLazy",
  opts = {
    current_only = false,   -- 所有窗口都显示
    winblend = 50,          -- 半透明
    zindex = 40,
    excluded_filetypes = {
      "snacks_explorer",
      "snacks_picker_input",
      "lazy",
      "mason",
      "aerial",
      "grug-far",
    },
    handlers = {
      cursor = {
        enable = true,      -- 显示光标位置
        symbols = { "⎯" },
      },
      search = {
        enable = true,      -- 显示搜索匹配
      },
      diagnostic = {
        enable = true,      -- 显示诊断标记
        signs = { "-", "=", "≡" },  -- 按严重程度区分
        min_severity = vim.diagnostic.severity.HINT,
      },
      gitsigns = {
        enable = true,      -- 显示 Git 变更标记（需要 gitsigns.nvim）
      },
      marks = {
        enable = true,      -- 显示标记位置
        show_builtins = false,
      },
    },
  },
}
