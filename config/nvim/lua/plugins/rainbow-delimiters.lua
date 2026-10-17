-- ========== rainbow-delimiters.nvim - 彩虹括号 ==========
-- 基于 Treesitter 的彩虹括号高亮

return {
  "HiPhish/rainbow-delimiters.nvim",
  event = "BufReadPost",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  -- 配置必须在插件附加到第一个 buffer 之前就绪，所以放在 init 而不是 config
  init = function()
    ---@type rainbow_delimiters.config
    vim.g.rainbow_delimiters = {
      strategy = {
        [""] = "rainbow-delimiters.strategy.global",
      },
      query = {
        [""] = "rainbow-delimiters",
      },
      highlight = {
        "RainbowDelimiterRed",
        "RainbowDelimiterYellow",
        "RainbowDelimiterBlue",
        "RainbowDelimiterOrange",
        "RainbowDelimiterGreen",
        "RainbowDelimiterViolet",
        "RainbowDelimiterCyan",
      },
    }
  end,
}
