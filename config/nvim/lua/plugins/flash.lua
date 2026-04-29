return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    -- 标签视觉优化
    label = {
      rainbow = { enabled = true }, -- 标签用彩色区分，不全是绿色
    },
    modes = {
      treesitter = {
        highlight = {
          backdrop = true, -- 非选中区域变暗，突出选中区域
        },
      },
    },
  },
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "闪跳" },
    { "S", mode = { "n", "o" }, function() require("flash").treesitter() end, desc = "语法树跳转" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "远程闪跳" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "语法树搜索" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "切换闪跳搜索" },
  },
}
