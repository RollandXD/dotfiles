-- ========== LSP 配置 ==========
-- nvim-lspconfig 的 lsp/*.lua 已提供各 server 的 cmd / filetypes / root_markers / 默认 on_attach，
-- 这里只写与默认不同的部分；通用键位等统一由 config/lsp-on-attach.lua 的 LspAttach 处理。

local servers = {
  "basedpyright",
  "clangd",
  "cmake",
  "copilot",
  "jsonls",
  "lua_ls",
  "marksman",
  "ruff",
  "taplo",
  "yamlls",
}

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "mason-org/mason.nvim",
    "mason-org/mason-lspconfig.nvim",
  },

  config = function()
    -- 日志只记错误：stderr 噪声曾把 lsp.log 撑到 400+ MB
    vim.lsp.log.set_level(vim.log.levels.ERROR)

    require("mason-lspconfig").setup({
      -- CMake LSP 由 pacman 管理；jdtls 由 nvim-jdtls 启动，但同样交给 Mason 安装
      ensure_installed = {
        "basedpyright",
        "clangd",
        "copilot",
        "jdtls",
        "jsonls",
        "lua_ls",
        "marksman",
        "ruff",
        "taplo",
        "yamlls",
      },
      automatic_enable = false,
    })

    require("config.lsp-on-attach").setup()

    -- 所有 server 共享 blink.cmp 的补全能力声明
    vim.lsp.config("*", {
      capabilities = require("blink.cmp").get_lsp_capabilities(),
    })

    -- ===== C / C++ =====
    vim.lsp.config("clangd", {
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=Google",
        "-j=4", -- 限制并发索引线程数
        "--pch-storage=memory", -- PCH 存内存，提升响应速度
      },
      init_options = {
        clangdFileStatus = true,
        usePlaceholders = true,
        completeUnimported = true,
      },
    })

    local function is_clangd_outline_action(action)
      local title = (action.title or ""):lower()
      return title:find("out-of-line", 1, true) ~= nil
        or title:find("move function body", 1, true) ~= nil
        or title:find("create definition", 1, true) ~= nil
        or title:find("define out", 1, true) ~= nil
        or title:find("implement", 1, true) ~= nil
    end

    local function create_cpp_implementation()
      -- 优先用 nt-cpp-tools（Treesitter，不依赖 clangd 索引），失败回退到 clangd
      if pcall(vim.cmd, "TSCppImplWrite") then
        return
      end
      vim.lsp.buf.code_action({ filter = is_clangd_outline_action, apply = true })
    end

    -- ===== JSON / YAML：SchemaStore 目录只在对应服务器真正启动时加载 =====
    local function add_schemastore(kind)
      return function(_, config)
        local ok, schemastore = pcall(require, "schemastore")
        if ok then
          config.settings[kind].schemas = schemastore[kind].schemas()
        end
      end
    end

    vim.lsp.config("jsonls", {
      before_init = add_schemastore("json"),
      settings = {
        json = { schemas = {}, validate = { enable = true } },
      },
    })

    vim.lsp.config("yamlls", {
      before_init = add_schemastore("yaml"),
      settings = {
        yaml = {
          -- 关掉内置的远程 SchemaStore，改用上面本地的 SchemaStore.nvim
          schemaStore = { enable = false, url = "" },
          schemas = {},
          validate = true,
        },
      },
    })

    -- ===== Lua：vim 全局变量与插件类型由 lazydev.nvim 注入 =====
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
        },
      },
    })

    -- ===== Python =====
    -- basedpyright：类型检查 / 补全 / 跳转 / hover（自带内置模块 docstring）。
    -- lspconfig 默认 disableTaggedHints = true，「未使用的 import」等只由 ruff 报一次。
    -- ruff：只做 lint 诊断与 code action；格式化走 conform（ruff_organize_imports + ruff_format）。
    local python_tools = require("config.python")
    vim.lsp.config("basedpyright", {
      before_init = function(params, config)
        local root = config.root_dir
          or (params.workspaceFolders and params.workspaceFolders[1] and vim.uri_to_fname(params.workspaceFolders[1].uri))
          or vim.fn.getcwd()
        config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
          python = { pythonPath = python_tools.python_path(root) },
        })
      end,
      settings = {
        basedpyright = {
          analysis = {
            diagnosticMode = "workspace",
            -- 保持 pyright 标准档的检查强度，避免 basedpyright 默认 recommended 档满屏警告
            typeCheckingMode = "standard",
          },
        },
      },
    })

    -- server 专属调整：在通用 LspAttach 之后再挂一层
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspServerTweaks", { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
          return
        end
        local bufnr = args.buf

        -- ruff 的 hover 只解释 noqa 规则码，会和 basedpyright 的文档拼在一起，关掉
        if client.name == "ruff" then
          client.server_capabilities.hoverProvider = false
        end

        if client.name == "clangd" then
          vim.keymap.set("n", "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>",
            { buffer = bufnr, desc = "切换头/源文件" })
          vim.keymap.set("n", "<leader>ci", create_cpp_implementation,
            { buffer = bufnr, desc = "为声明生成定义" })
        end
      end,
    })

    vim.lsp.enable(servers)
  end,
}
