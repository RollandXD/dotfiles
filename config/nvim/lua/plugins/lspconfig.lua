return {
  "neovim/nvim-lspconfig",
  lazy = false,
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },

  config = function()
    -- 安装 mason-lspconfig
    require("mason-lspconfig").setup({
      -- 自动安装的 LSP 服务器
      ensure_installed = { "jdtls", "clangd", "pyright", "yamlls", "taplo", "ruff" },  -- Java / C++ / Python + 配置文件 LSP（cmake-language-server 由 pacman 管理）
      automatic_installation = true,
      automatic_enable = false,
    })

    local function is_clangd_outline_action(action)
      local title = (action.title or ""):lower()
      return title:find("out-of-line", 1, true) ~= nil
        or title:find("move function body", 1, true) ~= nil
        or title:find("create definition", 1, true) ~= nil
        or title:find("define out", 1, true) ~= nil
        or title:find("implement", 1, true) ~= nil
    end

    local function createCppImplementation()
      -- 优先用 nt-cpp-tools（Treesitter，不依赖 clangd 索引），失败回退到 clangd
      local ok = pcall(vim.cmd, "TSCppImplWrite")
      if ok then
        return
      end

      vim.lsp.buf.code_action({
        filter = is_clangd_outline_action,
        apply = true,
      })
    end

    -- LSP 附加时的通用配置（从共享模块引入）
    local lsp_on_attach = require("config.lsp-on-attach")

    local on_attach = function(client, bufnr)
      -- 调用通用 on_attach（快捷键、inlay hints、document highlight 等）
      lsp_on_attach.on_attach(client, bufnr)

      -- clangd 专属快捷键
      if client.name == "clangd" then
        local opts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set("n", "<leader>ch", function()
          local params = { uri = vim.uri_from_bufnr(bufnr) }
          client:request("textDocument/switchSourceHeader", params, function(err, result)
            if err or not result then
              vim.notify("无法切换头/源文件", vim.log.levels.WARN)
              return
            end
            vim.cmd("edit " .. vim.uri_to_fname(result))
          end, bufnr)
        end, vim.tbl_extend("force", opts, { desc = "切换头/源文件" }))
        vim.keymap.set("n", "<leader>ci", createCppImplementation,
          vim.tbl_extend("force", opts, { desc = "为声明生成定义" }))
      end
    end

    -- 通用 LSP 能力配置（与 blink.cmp 集成）
    local capabilities = require("blink.cmp").get_lsp_capabilities()
    local python_tools = require("config.python")

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

    -- C / C++ LSP 配置
    vim.lsp.config("clangd", {
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=Google",
        "-j=4",                         -- 限制并发索引线程数
        "--pch-storage=memory",         -- PCH 存内存，提升响应速度
      },
      root_markers = { "compile_commands.json", "compile_flags.txt", ".clangd", ".git" },
      filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
      on_attach = on_attach,
      capabilities = vim.tbl_deep_extend("force", capabilities, {
        offsetEncoding = { "utf-16" },
      }),
      init_options = {
        clangdFileStatus = true,
        usePlaceholders = true,
        completeUnimported = true,
      },
    })

    -- CMake LSP 配置
    vim.lsp.config("cmake", {
      cmd = { "cmake-language-server" },
      root_markers = { "CMakeLists.txt", ".git" },
      filetypes = { "cmake" },
      on_attach = on_attach,
      capabilities = capabilities,
    })

    -- JSON LSP 配置（支持 SchemaStore 自动加载常见配置文件的 schema）
    local json_schemas = {}
    local schemastore_ok, schemastore = pcall(require, "schemastore")
    if schemastore_ok then
      json_schemas = schemastore.json.schemas()
    end
    vim.lsp.config("jsonls", {
      cmd = { "vscode-json-language-server", "--stdio" },
      filetypes = { "json", "jsonc" },
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        json = {
          schemas = json_schemas,
          validate = { enable = true },
        },
      },
    })

    -- YAML LSP 配置（pre-commit / GitHub Actions 等）
    local yaml_schemas = {}
    if schemastore_ok and schemastore.yaml then
      yaml_schemas = schemastore.yaml.schemas()
    end
    vim.lsp.config("yamlls", {
      cmd = { "yaml-language-server", "--stdio" },
      filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
      root_markers = { ".pre-commit-config.yaml", ".github", ".git" },
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        yaml = {
          schemaStore = {
            enable = false,
            url = "",
          },
          schemas = yaml_schemas,
          validate = true,
          hover = true,
          completion = true,
        },
      },
    })

    -- TOML LSP 配置（pyproject.toml / taplo.toml）
    vim.lsp.config("taplo", {
      cmd = { "taplo", "lsp", "stdio" },
      filetypes = { "toml" },
      root_markers = { "taplo.toml", ".taplo.toml", "pyproject.toml", ".git" },
      on_attach = on_attach,
      capabilities = capabilities,
    })

    -- Python LSP 配置
    vim.lsp.config("pyright", {
      cmd = { "pyright-langserver", "--stdio" },
      root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
      filetypes = { "python" },
      on_attach = on_attach,
      capabilities = capabilities,
      before_init = function(params, config)
        local root = config.root_dir
          or (params.workspaceFolders and params.workspaceFolders[1] and vim.uri_to_fname(params.workspaceFolders[1].uri))
          or vim.fn.getcwd()
        config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
          python = {
            pythonPath = python_tools.python_path(root),
          },
        })
      end,
      settings = {
        python = {
          pythonPath = python_tools.python_path(),
          analysis = {
            autoSearchPaths = true,
            diagnosticMode = "workspace",
            useLibraryCodeForTypes = true,
          },
        },
      },
    })

    -- 自动启用 LSP（当打开对应文件类型时）
    vim.lsp.enable("lua_ls")
    vim.lsp.enable("clangd")
    vim.lsp.enable("cmake")
    vim.lsp.enable("jsonls")
    vim.lsp.enable("yamlls")
    vim.lsp.enable("taplo")
    vim.lsp.enable("pyright")
  end,
}
