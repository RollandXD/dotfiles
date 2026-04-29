return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "VeryLazy",
  keys = {
    { "]t", function() require("todo-comments").jump_next() end, desc = "下一个 TODO" },
    { "[t", function() require("todo-comments").jump_prev() end, desc = "上一个 TODO" },
    { "<leader>ft", function() Snacks.picker.todo_comments() end, desc = "搜索 TODO" },
  },
  opts = {},
}
