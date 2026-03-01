return {
  "williamboman/mason.nvim",
  cmd = "Mason",  -- 输入 :Mason 时才加载
  keys = {
    { "<leader>m", "<cmd>Mason<cr>", desc = "打开 Mason" },
  },

  config = function()
    require("mason").setup({
      ui = {
        border = "rounded",  -- 圆角边框
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })
  end,
}
