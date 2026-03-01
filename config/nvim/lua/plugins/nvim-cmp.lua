return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",      -- LSP 补全源
    "hrsh7th/cmp-buffer",        -- 缓冲区补全源
    "hrsh7th/cmp-path",          -- 路径补全源
    "L3MON4D3/LuaSnip",          -- 代码片段引擎
    "saadparwaiz1/cmp_luasnip",  -- LuaSnip 补全源
  },

  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    cmp.setup({
      -- 代码片段引擎
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      -- 补全菜单样式
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },

      -- 快捷键映射（避免冲突）
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),   -- 文档向上滚动
        ["<C-f>"] = cmp.mapping.scroll_docs(4),    -- 文档向下滚动
        ["<C-p>"] = cmp.mapping.complete(),        -- 手动触发补全（Vim 传统补全键）
        ["<C-e>"] = cmp.mapping.abort(),           -- 关闭补全
        ["<CR>"] = cmp.mapping.confirm({ select = true }),  -- 确认选择（仅在补全菜单显示时生效）

        -- Tab 键切换补全项
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),

      -- 补全源优先级
      sources = cmp.config.sources({
        { name = "nvim_lsp" },    -- LSP 最优先
        { name = "luasnip" },     -- 代码片段
      }, {
        { name = "buffer" },      -- 当前缓冲区
        { name = "path" },        -- 文件路径
      }),
    })

    -- 与 nvim-autopairs 集成（修复回车键行为）
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  end,
}
