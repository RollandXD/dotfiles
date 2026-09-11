local root_markers = {
  "gradlew",
  "mvnw",
  "pom.xml",
  "build.gradle",
  "build.gradle.kts",
  "settings.gradle",
  "settings.gradle.kts",
  ".git",
}

local function find_java_home()
  if vim.env.JAVA_HOME and vim.env.JAVA_HOME ~= "" then
    return vim.env.JAVA_HOME
  end

  local java = vim.fn.resolve(vim.fn.exepath("java"))
  return vim.fs.dirname(vim.fs.dirname(java))
end

local function workspace_dir(root_dir)
  local name = vim.fs.basename(root_dir)
  local digest = vim.fn.sha256(root_dir):sub(1, 12)
  return vim.fs.joinpath(vim.fn.stdpath("cache"), "jdtls-workspace", name .. "-" .. digest)
end

local function debug_bundles()
  local pattern = vim.fs.joinpath(
    vim.fn.stdpath("data"),
    "mason",
    "packages",
    "java-debug-adapter",
    "extension",
    "server",
    "com.microsoft.java.debug.plugin-*.jar"
  )
  return vim.fn.glob(pattern, true, true)
end

return {
  "mfussenegger/nvim-jdtls",
  ft = "java",
  dependencies = {
    "mfussenegger/nvim-dap",
  },

  config = function()
    local jdtls = require("jdtls")
    local capabilities = require("blink.cmp").get_lsp_capabilities()

    local function start_or_attach(args)
      local filename = vim.api.nvim_buf_get_name(args.buf)
      if filename == "" then
        return
      end

      local root_dir = vim.fs.root(filename, root_markers) or vim.fs.dirname(filename)
      local java_home = find_java_home()
      local config = {
        cmd = {
          vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", "jdtls"),
          "-data",
          workspace_dir(root_dir),
        },
        root_dir = root_dir,
        capabilities = capabilities,
        settings = {
          java = {
            home = java_home,
            eclipse = {
              downloadSources = true,
            },
            configuration = {
              updateBuildConfiguration = "interactive",
              runtimes = {
                {
                  name = "JavaSE-21",
                  path = java_home,
                },
              },
            },
            maven = {
              downloadSources = true,
            },
            implementationsCodeLens = {
              enabled = true,
            },
            referencesCodeLens = {
              enabled = true,
            },
            format = {
              enabled = true,
            },
          },
          signatureHelp = { enabled = true },
        },
        init_options = {
          bundles = debug_bundles(),
        },
        on_attach = function(client, bufnr)
          require("config.lsp-on-attach").on_attach(client, bufnr)

          vim.keymap.set("n", "<leader>Jo", jdtls.organize_imports, { buffer = bufnr, desc = "整理 Java 导入" })
          vim.keymap.set("n", "<leader>Jv", jdtls.extract_variable, { buffer = bufnr, desc = "提取变量" })
          vim.keymap.set("v", "<leader>Jv", function()
            jdtls.extract_variable(true)
          end, { buffer = bufnr, desc = "提取变量（可视模式）" })
          vim.keymap.set("n", "<leader>Jc", jdtls.extract_constant, { buffer = bufnr, desc = "提取常量" })
          vim.keymap.set("v", "<leader>Jm", function()
            jdtls.extract_method(true)
          end, { buffer = bufnr, desc = "提取方法" })
        end,
      }

      jdtls.start_or_attach(config, { dap = { hotcodereplace = "auto" } }, { bufnr = args.buf })
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("UserJdtls", { clear = true }),
      pattern = "java",
      callback = start_or_attach,
    })

    if vim.bo.filetype == "java" then
      start_or_attach({ buf = vim.api.nvim_get_current_buf() })
    end
  end,
}
