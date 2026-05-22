-- ========== vim-tmux-navigator - Neovim/tmux 无缝导航 ==========

return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  init = function()
    -- 手动声明映射，避免覆盖 Snacks 的 <C-\> 浮动终端。
    vim.g.tmux_navigator_no_mappings = 1
  end,
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "移动到左侧窗口/pane" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "移动到下方窗口/pane" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "移动到上方窗口/pane" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "移动到右侧窗口/pane" },
  },
}
