-- ========== which-key.nvim - 快捷键提示 ==========
-- 按下 Leader 键后显示可用的快捷键

return {
  "folke/which-key.nvim",
  lazy = false,
  priority = 1000,
  dependencies = {
    "echasnovski/mini.icons",
    "nvim-tree/nvim-web-devicons",
  },
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 1000 -- 1s，适配慢速按键习惯
  end,
  config = function()
    local wk = require("which-key")

    wk.setup({
      delay = 0, -- 按下 Leader 后立即显示 which-key
      plugins = {
        marks = true,
        registers = true,
        spelling = {
          enabled = false,
        },
      },
      win = {
        border = "rounded",
      },
    })

    -- 新版 spec：使用 desc/group 字段
    wk.add({
      { "<leader>+", desc = "增大窗口" },
      { "<leader>-", desc = "减小窗口" },
      { "<leader>=", desc = "均分窗口" },
      { "<leader>f", group = "查找/搜索" },
      { "<leader>j", desc = "合并行" },
      { "<leader>q", desc = "退出" },
      { "<leader>w", desc = "保存文件" },
      { "<leader>y", desc = "剪切板历史" },
    })

    -- 兜底触发：显式挂载 Leader，避免自动 trigger 在个别环境下不生效
    vim.keymap.set({ "n", "v" }, "<leader>", function()
      require("which-key.state").start({ keys = "<leader>" })
    end, { nowait = true, silent = true, desc = "which-key-trigger" })
  end,
}
