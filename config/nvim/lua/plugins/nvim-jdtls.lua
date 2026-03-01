return {
  "mfussenegger/nvim-jdtls",
  ft = "java",  -- 只在打开 Java 文件时加载
  dependencies = {
    "mfussenegger/nvim-dap",  -- 依赖调试插件
  },

  config = function()
    local jdtls = require('jdtls')

    -- 获取 JDTLS 安装路径（Mason 会安装到这里）
    local jdtls_path = vim.fn.stdpath('data') .. '/mason/packages/jdtls'
    local launcher_jar = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')

    -- 根据操作系统选择配置目录
    local system = 'linux'
    if vim.fn.has('mac') == 1 then
      system = 'mac'
    elseif vim.fn.has('win32') == 1 then
      system = 'win'
    end
    local config_dir = jdtls_path .. '/config_' .. system

    -- 工作空间目录（每个项目独立，避免冲突）
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
    local workspace_dir = vim.fn.stdpath('cache') .. '/jdtls-workspace/' .. project_name

    -- JDTLS 配置
    local config = {
      cmd = {
        'java',  -- 使用系统的 Java 21
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xmx1g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
        '-jar', launcher_jar,
        '-configuration', config_dir,
        '-data', workspace_dir,
      },

      -- 项目根目录检测（按优先级查找）
      root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle'}),

      -- Java 运行时配置
      settings = {
        java = {
          home = '/usr/lib/jvm/java-21-openjdk-amd64',  -- Java 21 路径
          eclipse = {
            downloadSources = true,  -- 自动下载依赖源码
          },
          configuration = {
            updateBuildConfiguration = "interactive",
            runtimes = {
              {
                name = "JavaSE-21",
                path = "/usr/lib/jvm/java-21-openjdk-amd64",
              }
            }
          },
          maven = {
            downloadSources = true,
          },
          implementationsCodeLens = {
            enabled = true,  -- 显示实现数量
          },
          referencesCodeLens = {
            enabled = true,  -- 显示引用数量
          },
          format = {
            enabled = true,  -- 启用代码格式化
          },
        },
        signatureHelp = { enabled = true },  -- 参数提示
      },

      -- 初始化选项（加载调试器和测试支持）
      init_options = {
        bundles = {}  -- 这里可以添加 java-debug-adapter 的 jar 包路径
      },

      -- LSP 快捷键配置（继承现有风格）
      on_attach = function(client, bufnr)
        local opts = { noremap = true, silent = true, buffer = bufnr }

        -- 使用现有的快捷键风格
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "gh", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        -- Java 特有快捷键
        vim.keymap.set("n", "<leader>jo", jdtls.organize_imports, { buffer = bufnr, desc = "整理 Java 导入" })
        vim.keymap.set("n", "<leader>jv", jdtls.extract_variable, { buffer = bufnr, desc = "提取变量" })
        vim.keymap.set("v", "<leader>jv", function()
          jdtls.extract_variable(true)
        end, { buffer = bufnr, desc = "提取变量（可视模式）" })
        vim.keymap.set("n", "<leader>jc", jdtls.extract_constant, { buffer = bufnr, desc = "提取常量" })
        vim.keymap.set("v", "<leader>jm", function()
          jdtls.extract_method(true)
        end, { buffer = bufnr, desc = "提取方法" })
      end,

      -- 代码补全能力（与 nvim-cmp 集成）
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
    }

    -- 启动或附加到 JDTLS 服务器
    jdtls.start_or_attach(config)
  end
}
