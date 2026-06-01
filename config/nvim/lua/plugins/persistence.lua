-- ========== persistence.nvim - 自动会话管理 ==========
-- 替代手写的 session.lua，自动按目录保存/恢复会话

return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {
    dir = vim.fn.stdpath("state") .. "/sessions/",
    need = 1,           -- 至少有 1 个 buffer 才保存会话
    branch = true,      -- 按 Git 分支区分会话
  },
  keys = {
    { "<leader>Ps", function() require("persistence").load() end, desc = "恢复当前目录会话" },
    { "<leader>Pl", function() require("persistence").load({ last = true }) end, desc = "恢复最近会话" },
    { "<leader>Pd", function() require("persistence").stop() end, desc = "不保存退出" },
  },
}
