-- ========== Yanky.nvim - 剪切板历史管理 ==========
-- 保存多条复制历史，支持 snacks.picker 可视化选择

return {
  "gbprod/yanky.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>y", function() Snacks.picker.yanky() end, desc = "剪切板历史" },
    { "p", "<Plug>(YankyPutAfter)", mode = "n", desc = "粘贴" },
    { "P", "<Plug>(YankyPutBefore)", mode = "n", desc = "向前粘贴" },
  },
  config = function()
    require("yanky").setup({
      ring = {
        history_length = 100,
        storage = "shada",
        sync_with_numbered_registers = true,
      },
      highlight = {
        on_put = true,
        on_yank = true,
        timer = 300,
      },
      preserve_cursor_position = {
        enabled = true,
      },
    })
  end,
}
