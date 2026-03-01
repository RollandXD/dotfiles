-- ========== Comment.nvim - 快速注释 ==========
-- gcc - 注释/取消注释当前行
-- gc + motion - 注释选中区域
-- gbc - 块注释

return {
  "numToStr/Comment.nvim",
  keys = {
    { "gcc", mode = "n", desc = "注释/取消注释行" },
    { "gc", mode = { "n", "v" }, desc = "注释" },
    { "gbc", mode = "n", desc = "块注释" },
    { "gb", mode = { "n", "v" }, desc = "块注释" },
  },
  config = function()
    require('Comment').setup({
      -- 基本映射
      toggler = {
        line = 'gcc',  -- 行注释
        block = 'gbc',  -- 块注释
      },
      opleader = {
        line = 'gc',
        block = 'gb',
      },

      -- 额外映射
      extra = {
        above = 'gcO',  -- 在上方添加注释
        below = 'gco',  -- 在下方添加注释
        eol = 'gcA',    -- 在行尾添加注释
      },
    })
  end,
}
