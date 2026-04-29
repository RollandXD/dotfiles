return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "Trouble",
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "全局诊断" },
    { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "当前文件诊断" },
    { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "快速修复列表" },
  },
  opts = {},
}
