-- ========== nvim-treesitter-context - 代码上下文固定显示 ==========
-- 在屏幕顶部显示当前函数/类/方法签名

return {
  "nvim-treesitter/nvim-treesitter-context",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = "BufReadPost",
  opts = {
    enable = true,
    max_lines = 3,           -- 最多显示 3 行上下文
    min_window_height = 20,  -- 窗口太小时不显示
    multiline_threshold = 5, -- 超过 5 行的节点才合并
    trim_scope = "outer",    -- 超出时裁剪外层
    mode = "cursor",         -- 基于光标位置
    separator = "─",         -- 上下文和代码之间的分隔线
  },
  keys = {
    {
      "<leader>tc",
      function()
        require("treesitter-context").toggle()
      end,
      desc = "切换代码上下文",
    },
    {
      "[C",
      function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end,
      desc = "跳转到上下文",
    },
  },
}
