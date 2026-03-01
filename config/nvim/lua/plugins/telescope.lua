-- ========== Telescope - 模糊搜索引擎 ==========
-- Neovim 版的 fzf，功能更强大

return {
  -- Telescope 主插件
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",  -- 使用最新版本（需要 Neovim 0.10+）
    dependencies = {
      "nvim-lua/plenary.nvim",  -- Lua 工具库（必需）
    },
    cmd = "Telescope",  -- 延迟加载，使用 :Telescope 命令时才加载
    keys = {
      -- 文件搜索
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "搜索文件" },

      -- 全局文本搜索（需要 ripgrep）
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "全局搜索文本" },

      -- Buffer 列表
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffer 列表" },

      -- 命令历史
      { "<leader>fh", "<cmd>Telescope command_history<cr>", desc = "命令历史" },

      -- 帮助文档搜索
      { "<leader>fH", "<cmd>Telescope help_tags<cr>", desc = "搜索帮助文档" },

      -- 最近打开的文件
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "最近文件" },

      -- 快捷键搜索
      { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "快捷键列表" },
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')

      telescope.setup({
        defaults = {
          -- 默认主题
          -- theme = "dropdown",

          -- 布局配置
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
            },
            width = 0.87,
            height = 0.80,
          },

          -- 搜索时的排序策略
          sorting_strategy = "ascending",

          -- 文件忽略模式
          file_ignore_patterns = {
            "node_modules",
            ".git/",
            "%.jpg",
            "%.png",
          },

          -- 快捷键映射
          mappings = {
            i = {  -- 插入模式
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<Esc>"] = actions.close,
              ["<C-c>"] = actions.close,
            },
            n = {  -- 正常模式
              ["q"] = actions.close,
            },
          },
        },

        -- 各个 picker 的配置
        pickers = {
          find_files = {
            -- 显示隐藏文件
            hidden = true,
          },
        },
      })
    end,
  },
}
