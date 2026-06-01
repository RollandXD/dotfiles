-- ========== grapple.nvim - 文件标签快速导航 ==========
-- 标记常用文件，用数字键一键跳转
-- 配合 grapple-line.nvim 在状态栏显示标签

return {
  -- Grapple 主插件
  {
    "cbochs/grapple.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Grapple",
    -- 移除 event 加载，仅在使用快捷键/命令时才加载
    opts = {
      scope = "git",              -- 按 Git 仓库自动分组
      icons = true,               -- 显示文件图标
      quick_select = "1234567890", -- 快速选择键
    },
    keys = {
      { "<leader>ll", "<cmd>Grapple toggle<cr>", desc = "标记/取消标记文件" },
      { "<leader>lt", "<cmd>Grapple toggle_tags<cr>", desc = "标签管理窗口" },
      { "<leader>1", "<cmd>Grapple select index=1<cr>", desc = "跳转标签 1" },
      { "<leader>2", "<cmd>Grapple select index=2<cr>", desc = "跳转标签 2" },
      { "<leader>3", "<cmd>Grapple select index=3<cr>", desc = "跳转标签 3" },
      { "<leader>4", "<cmd>Grapple select index=4<cr>", desc = "跳转标签 4" },
      { "<leader>5", "<cmd>Grapple select index=5<cr>", desc = "跳转标签 5" },
      { "<leader>6", "<cmd>Grapple select index=6<cr>", desc = "跳转标签 6" },
      { "<leader>7", "<cmd>Grapple select index=7<cr>", desc = "跳转标签 7" },
      { "<leader>8", "<cmd>Grapple select index=8<cr>", desc = "跳转标签 8" },
      { "<leader>9", "<cmd>Grapple select index=9<cr>", desc = "跳转标签 9" },
    },
  },

  -- Grapple-Line: 在 lualine 显示标记的文件
  {
    "will-lynas/grapple-line.nvim",
    dependencies = {
      "cbochs/grapple.nvim",
      "nvim-lualine/lualine.nvim",
    },
    opts = {
      -- 未选中标签的格式
      number_of_files = 9,          -- 显示最多 9 个标签
      colors = {
        active = "lualine_a_normal",   -- 当前文件标签的高亮
        inactive = "lualine_b_normal", -- 其他标签的高亮
      },
    },
  },
}
