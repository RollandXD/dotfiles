return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,  -- 优先加载（确保在其他插件之前应用主题）
  lazy = false,     -- 立即加载

  config = function()
    require("catppuccin").setup({
      flavour = "frappe",  -- 变体：latte, frappe, macchiato, mocha
      transparent_background = false,  -- 透明背景
      -- 按 lazy.nvim 已安装的插件自动启用对应集成（grug-far、mason、ufo、rainbow 等都会覆盖到）
      auto_integrations = true,
      integrations = {
        blink_cmp = { style = "bordered" },
      },
    })

    -- 应用主题
    vim.cmd.colorscheme("catppuccin")

    -- LSP 变量高亮（与 Visual 选中区分开，用青色系）
    vim.api.nvim_set_hl(0, "LspReferenceText",  { bg = "#314153" })
    vim.api.nvim_set_hl(0, "LspReferenceRead",  { bg = "#314153" })
    vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "#3d3b58" })
  end,
}
