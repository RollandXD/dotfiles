-- ========== vim-tmux-navigator - Neovim/tmux 无缝导航 ==========

return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  init = function()
    -- 手动声明映射，释放 Ctrl-hjkl 给编辑器和其他插件。
    vim.g.tmux_navigator_no_mappings = 1
  end,
  keys = {
    { "<A-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "移动到左侧窗口/pane" },
    { "<A-j>", "<cmd>TmuxNavigateDown<cr>", desc = "移动到下方窗口/pane" },
    { "<A-k>", "<cmd>TmuxNavigateUp<cr>", desc = "移动到上方窗口/pane" },
    { "<A-l>", "<cmd>TmuxNavigateRight<cr>", desc = "移动到右侧窗口/pane" },
  },
}
