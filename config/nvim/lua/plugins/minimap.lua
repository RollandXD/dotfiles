-- neominimap 已被 satellite.nvim 替代
-- 如需恢复，取消下面的注释并删除 satellite.lua

return {}

--[[
return {
  "Isrothy/neominimap.nvim",
  version = "v3.x.x",
  lazy = false,
  init = function()
    vim.opt.sidescrolloff = 36
    vim.g.neominimap = {
      auto_enable = true,
      layout = "float",
      float = {
        minimap_width = 12,
        margin = { right = 0, top = 0, bottom = 0 },
      },
      treesitter = { enabled = true, priority = 200 },
      diagnostic = { enabled = true, mode = "line" },
      git = { enabled = true, mode = "sign" },
      search = { enabled = true, mode = "line" },
    }
  end,
  keys = {
    { "<leader>um", "<cmd>Neominimap Toggle<cr>", desc = "切换代码缩略图" },
    { "<leader>uM", "<cmd>Neominimap ToggleFocus<cr>", desc = "聚焦代码缩略图" },
  },
}
--]]
