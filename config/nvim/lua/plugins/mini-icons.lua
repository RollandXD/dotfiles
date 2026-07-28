-- ========== mini.icons - 图标提供者 ==========
-- snacks（explorer / picker / dashboard）优先向全局 MiniIcons 取图标，
-- 取不到才退回 nvim-web-devicons —— 而 devicons 对所有目录返回同一个 󰉋。
-- 这里 setup 之后，文件夹就会按名字区分图标（src / test / docs / node_modules ...）。

return {
  "echasnovski/mini.icons",
  lazy = false,
  priority = 1100, -- 必须早于 snacks（priority = 1000）
  opts = {
    -- 内置目录表只覆盖了语言无关的常见名（src/test/docs/bin/lib/node_modules 等），
    -- 下面补充前后端项目里高频出现、但内置表没有的目录名。
    directory = {
      api        = { glyph = "󱂛", hl = "MiniIconsGreen"  },
      app        = { glyph = "󱂵", hl = "MiniIconsBlue"   },
      assets     = { glyph = "󰉏", hl = "MiniIconsOrange" },
      components = { glyph = "󰅴", hl = "MiniIconsAzure"  },
      config     = { glyph = "󱁿", hl = "MiniIconsCyan"   },
      dist       = { glyph = "󱧼", hl = "MiniIconsGrey"   },
      hooks      = { glyph = "󰛢", hl = "MiniIconsPurple" },
      images     = { glyph = "󰉏", hl = "MiniIconsOrange" },
      include    = { glyph = "󰉋", hl = "MiniIconsPurple" },
      layouts    = { glyph = "󰙅", hl = "MiniIconsAzure"  },
      models     = { glyph = "󰆼", hl = "MiniIconsYellow" },
      out        = { glyph = "󱧼", hl = "MiniIconsGrey"   },
      pages      = { glyph = "󰑽", hl = "MiniIconsAzure"  },
      public     = { glyph = "󱧰", hl = "MiniIconsOrange" },
      routes     = { glyph = "󱂑", hl = "MiniIconsGreen"  },
      scripts    = { glyph = "󱆃", hl = "MiniIconsYellow" },
      services   = { glyph = "󰒓", hl = "MiniIconsGreen"  },
      store      = { glyph = "󰆼", hl = "MiniIconsYellow" },
      styles     = { glyph = "󰉼", hl = "MiniIconsPurple" },
      target     = { glyph = "󱧼", hl = "MiniIconsGrey"   },
      types      = { glyph = "󰬛", hl = "MiniIconsBlue"   },
      utils      = { glyph = "󱁤", hl = "MiniIconsCyan"   },
      views      = { glyph = "󰛅", hl = "MiniIconsAzure"  },
    },
  },
  config = function(_, opts)
    require("mini.icons").setup(opts)
    -- 让依赖 nvim-web-devicons 的插件（lualine / trouble / aerial / grapple ...）
    -- 也走 mini.icons，避免同一个文件在不同 UI 里显示两套图标。
    require("mini.icons").mock_nvim_web_devicons()
  end,
}
