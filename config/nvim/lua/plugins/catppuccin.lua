return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,  -- 优先加载（确保在其他插件之前应用主题）
  lazy = false,     -- 立即加载

  config = function()
    require("catppuccin").setup({
      flavour = "mocha",  -- 变体：latte, frappe, macchiato, mocha
      transparent_background = false,  -- 透明背景
      integrations = {
        cmp = true,
        treesitter = true,
        telescope = { enabled = true },
        which_key = true,
        -- 后续可按需启用更多集成
      },
    })

    -- 应用主题
    vim.cmd.colorscheme("catppuccin")
  end,
}
