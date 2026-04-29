-- ========== blink.cmp - 高性能补全引擎 ==========
-- 替代 nvim-cmp，Rust 核心模糊匹配，更快更简洁
-- 使用 super-tab 预设：Tab 选中+确认，Enter 永远换行

return {
  "saghen/blink.cmp",
  version = "1.*",
  event = "InsertEnter",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = "super-tab",
      -- super-tab 预设自带：
      -- Tab:   菜单打开 → 选中第一项并确认 / snippet 跳转 / 否则插入 Tab
      -- S-Tab: snippet 回退
      -- C-n/C-p: 上下浏览补全列表
      -- C-e:   关闭补全菜单
      -- C-space: 手动触发补全
      -- Enter: 永远是换行（不参与补全）

      -- 额外自定义（覆盖预设中的对应键）
      ["<C-b>"] = { "scroll_documentation_up" },
      ["<C-f>"] = { "scroll_documentation_down" },
    },
    appearance = {
      nerd_font_variant = "mono",
    },
    completion = {
      list = {
        selection = {
          -- snippet 激活时不预选，避免 Tab 跳转与补全选择冲突
          preselect = function(ctx)
            return not require("blink.cmp").snippet_active({ direction = 1 })
          end,
          auto_insert = true,
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      },
      menu = {
        border = "rounded",
        max_height = 10,
      },
      ghost_text = { enabled = false }, -- 避免与 Copilot 幽灵文本冲突
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      per_filetype = {
        sql = { "dadbod", "snippets", "buffer" },
        mysql = { "dadbod", "snippets", "buffer" },
        plsql = { "dadbod", "snippets", "buffer" },
      },
      providers = {
        snippets = {
          opts = {
            search_paths = { vim.fn.stdpath("config") .. "/snippets" },
          },
        },
        dadbod = {
          name = "Dadbod",
          module = "vim_dadbod_completion.blink",
        },
      },
    },
  },
}
