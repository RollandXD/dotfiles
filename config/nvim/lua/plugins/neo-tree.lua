return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",  -- 文件图标
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",  -- 输入 :Neotree 时才加载
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "文件树" },
  },

  config = function()
    require("neo-tree").setup({
      close_if_last_window = true,  -- 最后一个窗口时自动关闭
      window = {
        width = 30,  -- 宽度
        position = "left",
      },
      filesystem = {
        follow_current_file = {
          enabled = true,  -- 自动定位当前文件
        },
        hijack_netrw_behavior = "open_current",  -- 替代 netrw
      },
    })
  end,
}
