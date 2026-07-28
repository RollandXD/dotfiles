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
      ensure_installed = { "jdtls", "clangd", "pyright", "yamlls", "taplo", "ruff", "jedi_language_server" },  -- Java / C++ / Python(+jedi 补 hover) + 配置文件 LSP（cmake-language-server 由 pacman 管理）
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

    -- pyright 会为「未使用的 import / 变量」额外发一条 Hint 级诊断（如 `"sys" is not accessed`），
    -- 内容与 ruff 的 F401 完全重合，同一行会出现两条。它是 pyright 硬编码行为，
    -- diagnosticSeverityOverrides 关不掉，客户端 handlers 在 Neovim 0.12 的诊断路径上也不会被调用。
    -- 可行的是按 namespace 收敛显示层：pyright 的 Hint 不再渲染，同样的问题交给 ruff 报（还能一键修复）。
    --
    -- 注意 namespace 的实际名字是 `nvim.lsp.pyright.<client_id>.<server 自报的 identifier>`，
    -- vim.lsp.diagnostic.get_namespace() 返回的是不带 identifier 后缀的那个，对不上，
    -- 所以这里按名字前缀匹配；namespace 要等第一批诊断到达才创建，因此挂在 DiagnosticChanged 上。
    local muted_ns = {}
    vim.api.nvim_create_autocmd("DiagnosticChanged", {
      group = vim.api.nvim_create_augroup("UserMutePyrightHints", { clear = true }),
      callback = function()
        local at_least_info = { min = vim.diagnostic.severity.INFO }
        for name, ns in pairs(vim.api.nvim_get_namespaces()) do
          if not muted_ns[ns] and name:match("^nvim%.lsp%.pyright%.%d+") then
            muted_ns[ns] = true
            vim.diagnostic.config({
              virtual_text = { severity = at_least_info },
              signs = { severity = at_least_info },
              underline = { severity = at_least_info },
            }, ns)
          end
        end
      end,
    })

    local on_attach = function(client, bufnr)
      -- 调用通用 on_attach（快捷键、inlay hints、document highlight 等）
      lsp_on_attach.on_attach(client, bufnr)

      -- ===== Python 三个 server 的分工（避免能力重叠导致补全重复、gd 弹选择列表）=====
      -- pyright: 类型检查 / 补全 / 跳转 / 重命名   jedi: 只做 hover   ruff: 只做 lint 诊断 + code action
      local sc = client.server_capabilities

      -- pyright 交出 hover，交给 jedi（jedi 能读运行时 __doc__，补上 pyright 对 builtins 缺失的 docstring）
      if client.name == "pyright" then
        sc.hoverProvider = false
      end

      -- jedi 只保留 hover，其余能力全部交还 pyright，否则补全项与定义位置都会出现两份
      if client.name == "jedi_language_server" then
        sc.completionProvider = nil
        sc.signatureHelpProvider = nil
        sc.definitionProvider = false
        sc.typeDefinitionProvider = false
        sc.declarationProvider = false
        sc.implementationProvider = false
        sc.referencesProvider = false
        sc.renameProvider = false
        sc.documentSymbolProvider = false
        sc.workspaceSymbolProvider = false
        sc.codeActionProvider = false
        sc.documentHighlightProvider = false
        sc.inlayHintProvider = false
      end

      -- ruff 只做 lint 诊断和 code action（自动删未用 import 等），格式化仍走 conform
      if client.name == "ruff" then
        sc.hoverProvider = false
        sc.completionProvider = nil
        sc.definitionProvider = false
        sc.referencesProvider = false
        sc.renameProvider = false
        sc.documentFormattingProvider = false
        sc.documentRangeFormattingProvider = false
      end

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

    -- Ruff LSP：提供 lint 诊断与 code action（如「移除未使用的 import」），
    -- 格式化不交给它（由 conform 的 ruff_organize_imports / ruff_format 负责）
    -- 注：cmd 是启动进程时使用的静态值，无法按 buffer 切换；ruff 的 lint 规则读项目
    -- 自己的 pyproject.toml / ruff.toml，所以用哪个二进制对结果影响很小。
    -- 真正需要项目内 ruff 版本的场景（conform 格式化、CLI 任务）都已走 python_tools.executable。
    vim.lsp.config("ruff", {
      cmd = { python_tools.executable("ruff"), "server" },
      filetypes = { "python" },
      root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", "setup.py", "setup.cfg", ".git" },
      on_attach = on_attach,
      capabilities = capabilities,
    })

    -- Jedi：只负责 hover 文档（能读运行时 __doc__，补上 pyright 对 builtins 缺失的 docstring）
    vim.lsp.config("jedi_language_server", {
      cmd = { "jedi-language-server" },
      filetypes = { "python" },
      root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
      on_attach = on_attach,
      capabilities = capabilities,
      before_init = function(params, config)
        local root = config.root_dir
          or (params.workspaceFolders and params.workspaceFolders[1] and vim.uri_to_fname(params.workspaceFolders[1].uri))
          or vim.fn.getcwd()
        config.init_options = vim.tbl_deep_extend("force", config.init_options or {}, {
          workspace = {
            environmentPath = python_tools.python_path(root),
          },
        })
      end,
    })

    -- 自动启用 LSP（当打开对应文件类型时）
    vim.lsp.enable("lua_ls")
    vim.lsp.enable("clangd")
    vim.lsp.enable("cmake")
    vim.lsp.enable("jsonls")
    vim.lsp.enable("yamlls")
    vim.lsp.enable("taplo")
    vim.lsp.enable("pyright")
    vim.lsp.enable("jedi_language_server")
    vim.lsp.enable("ruff")
  end,
}
