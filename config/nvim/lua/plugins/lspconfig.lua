return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },

  config = function()
    -- 安装 mason-lspconfig
    require("mason-lspconfig").setup({
      -- 自动安装的 LSP 服务器
      ensure_installed = { "jdtls" },  -- Java LSP 服务器
      automatic_installation = true,
    })

    -- LSP 附加时的通用配置
    local on_attach = function(client, bufnr)
      local opts = { noremap = true, silent = true, buffer = bufnr }

      -- 代码导航快捷键（避免与用户现有配置冲突）
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)        -- 跳转到定义
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)        -- 查找引用
      vim.keymap.set("n", "gh", vim.lsp.buf.hover, opts)             -- 显示文档（改为 gh，避免与 K 冲突）
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)  -- 代码操作
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)       -- 重命名
    end

    -- 通用 LSP 能力配置（与 nvim-cmp 集成）
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- Lua LSP 配置（用于编辑 Neovim 配置）
    -- 使用新的 vim.lsp.config API（Neovim 0.11+）
    vim.lsp.config("lua_ls", {
      cmd = { "lua-language-server" },
      root_markers = { ".luarc.json", ".git" },
      filetypes = { "lua" },
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = {
            globals = { "vim" },  -- 识别 vim 全局变量
          },
          workspace = {
            checkThirdParty = false,
            library = { vim.env.VIMRUNTIME },
          },
          telemetry = { enable = false },
        },
      },
    })

    -- 自动启用 LSP（当打开对应文件类型时）
    vim.lsp.enable("lua_ls")
  end,
}
