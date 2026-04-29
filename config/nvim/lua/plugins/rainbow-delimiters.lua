-- ========== rainbow-delimiters.nvim - 彩虹括号 ==========
-- 基于 Treesitter 的彩虹括号高亮

return {
  "HiPhish/rainbow-delimiters.nvim",
  event = "BufReadPost",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    local rainbow = require("rainbow-delimiters")

    ---@type rainbow_delimiters.config
    vim.g.rainbow_delimiters = {
      strategy = {
        [""] = rainbow.strategy["global"],
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
