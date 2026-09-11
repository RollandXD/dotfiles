-- ========== TreeSJ - 结构化拆分/合并 ==========
-- 在单行与多行的参数、列表、字典、代码块之间智能切换。

return {
  "Wansmer/treesj",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  keys = {
    {
      "<leader>cj",
      function()
        require("treesj").toggle()
      end,
      desc = "拆分/合并代码结构",
    },
  },
  opts = {
    use_default_keymaps = false,
  },
}
