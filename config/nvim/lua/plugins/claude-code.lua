-- ========== claudecode.nvim - Claude Code IDE 集成 ==========
-- 让 Neovim 可以启动 Claude Code、发送选区/文件上下文，并接收 Claude 的 diff。

return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  cmd = {
    "ClaudeCode",
    "ClaudeCodeFocus",
    "ClaudeCodeSelectModel",
    "ClaudeCodeAdd",
    "ClaudeCodeSend",
    "ClaudeCodeDiffAccept",
    "ClaudeCodeDiffDeny",
  },
  opts = {
    terminal_cmd = "/home/rolland/.local/bin/claude",
    focus_after_send = false,
    terminal = {
      provider = "snacks",
      split_side = "right",
      split_width_percentage = 0.35,
    },
    diff_opts = {
      layout = "vertical",
      open_in_new_tab = false,
      keep_terminal_focus = false,
    },
  },
  keys = {
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "打开/关闭 Claude Code" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "聚焦 Claude Code" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "恢复 Claude 会话" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "继续 Claude 会话" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "选择 Claude 模型" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "加入当前 Buffer" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "发送选区给 Claude" },
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "接受 Claude Diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "拒绝 Claude Diff" },
  },
}
