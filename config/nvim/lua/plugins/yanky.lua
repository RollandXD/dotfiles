-- ========== Yanky.nvim - 剪切板历史管理 ==========
-- 保存多条复制历史，支持 Telescope 可视化选择

return {
  "gbprod/yanky.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",  -- Telescope 集成
  },
  event = "VeryLazy",
  keys = {
    -- 打开剪切板历史（Telescope 界面）
    { "<leader>y", "<cmd>Telescope yank_history<cr>", desc = "剪切板历史" },

    -- 粘贴
    { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "粘贴" },
    { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "向前粘贴" },

    -- 粘贴后循环切换历史
    { "<c-p>", "<Plug>(YankyCycleForward)", desc = "下一条剪切板" },
    { "<c-n>", "<Plug>(YankyCycleBackward)", desc = "上一条剪切板" },
  },
  config = function()
    local actions = require("telescope.actions")

    require("yanky").setup({
      -- 保存历史条数
      ring = {
        history_length = 100,
        storage = "shada",  -- 持久化存储
        sync_with_numbered_registers = true,
      },

      -- 高亮粘贴内容
      highlight = {
        on_put = true,
        on_yank = true,
        timer = 300,  -- 高亮持续时间（毫秒）
      },

      -- 保留粘贴时的光标位置
      preserve_cursor_position = {
        enabled = true,
      },

      -- 覆盖 yank_history 内部默认映射，避免 <C-k> 触发粘贴
      picker = {
        telescope = {
          use_default_mappings = true,
          mappings = {
            i = {
              ["<c-j>"] = actions.move_selection_next,
              ["<c-k>"] = actions.move_selection_previous,
            },
          },
        },
      },
    })

    -- Telescope 集成
    require("telescope").load_extension("yank_history")
  end,
}
