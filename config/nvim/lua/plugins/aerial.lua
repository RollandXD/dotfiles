return {
  "stevearc/aerial.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>o", "<cmd>AerialToggle!<cr>", desc = "符号大纲" },
  },
  opts = {
    backends = { "treesitter", "lsp", "markdown", "man" },
    filter_kind = {
      "Class",
      "Constructor",
      "Enum",
      "Function",
      "Interface",
      "Method",
      "Module",
      "Namespace",
      "Struct",
    },
    layout = {
      min_width = 28,
      default_direction = "prefer_right",
    },
    show_guides = true,
    guides = {
      mid_item = "├─",
      last_item = "└─",
      nested_top = "│ ",
      whitespace = "  ",
    },
  },
}
