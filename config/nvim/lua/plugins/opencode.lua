local opencode_cmd = "opencode --port"
local terminal_opts = {
  interactive = true,
  start_insert = true,
  auto_insert = true,
  win = {
    position = "right",
    width = 0.35,
    enter = true,
    border = "rounded",
    wo = { winbar = "" },
  },
}

return {
  "nickjvandyke/opencode.nvim",
  version = "*",
  init = function()
    vim.g.opencode_opts = {
      server = {
        start = function()
          require("snacks").terminal.open(opencode_cmd, terminal_opts)
        end,
      },
    }
  end,
  keys = {
    {
      "<leader>aa",
      function()
        require("opencode").ask("@this: ")
      end,
      mode = { "n", "x" },
      desc = "询问 OpenCode",
    },
    {
      "<leader>ap",
      function()
        require("opencode").prompt("@this ")
      end,
      mode = { "n", "x" },
      desc = "追加上下文到 OpenCode",
    },
    {
      "<leader>ae",
      function()
        require("opencode").prompt("Explain @this")
      end,
      mode = { "n", "x" },
      desc = "解释当前代码",
    },
    {
      "<leader>ar",
      function()
        require("opencode").prompt("Review @this")
      end,
      mode = { "n", "x" },
      desc = "审查当前代码",
    },
    {
      "<leader>am",
      function()
        require("opencode").prompt("Implement @this")
      end,
      mode = { "n", "x" },
      desc = "实现当前代码",
    },
    {
      "<leader>as",
      function()
        require("opencode").select()
      end,
      mode = { "n", "x" },
      desc = "选择 OpenCode 操作",
    },
    {
      "<C-.>",
      function()
        require("snacks").terminal.focus(opencode_cmd, terminal_opts)
      end,
      mode = { "n", "t" },
      desc = "切换备用 OpenCode 终端",
    },
  },
}
