return {
  "OXY2DEV/markview.nvim",
  lazy = false,      -- 官方建议不要 lazy load 
  -- ft = "markdown" -- 如果真的需要可以开启这行并注释上一行

  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons"
  },
  opts = {
    -- markview 默认已经配置好了绝佳的效果
    -- 如果需要自定义样式，可以在这里覆写
  }
}
