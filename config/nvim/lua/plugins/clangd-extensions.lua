-- ========== clangd_extensions.nvim - Clangd 扩展功能 ==========
-- 提供 clangd 非标准 LSP 扩展：类型层次、AST 查看、内存布局等
-- LazyVim / AstroNvim 均默认集成此插件

return {
  "p00f/clangd_extensions.nvim",
  ft = { "c", "cpp", "objc", "objcpp" },
  dependencies = { "neovim/nvim-lspconfig" },
  keys = {
    { "<leader>cT", "<cmd>ClangdTypeHierarchy<cr>", ft = { "c", "cpp" }, desc = "类型层次" },
    { "<leader>ca", "<cmd>ClangdAST<cr>", ft = { "c", "cpp" }, desc = "查看 AST" },
    { "<leader>cm", "<cmd>ClangdMemoryUsage<cr>", ft = { "c", "cpp" }, desc = "内存布局" },
  },
  opts = {
    inlay_hints = {
      inline = false,  -- 使用 Neovim 0.10+ 原生 inlay hints，不用插件的
    },
    ast = {
      -- 需要 Nerd Font 图标
      role_icons = {
        type = "",
        declaration = "",
        expression = "",
        specifier = "",
        statement = "",
        ["template argument"] = "",
      },
      kind_icons = {
        Compound = "",
        Recovery = "",
        TranslationUnit = "",
        PackExpansion = "",
        TemplateTypeParm = "",
        TemplateTemplateParm = "",
        TemplateParamObject = "",
      },
    },
  },
}
