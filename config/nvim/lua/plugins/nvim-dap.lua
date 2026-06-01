return {
  -- DAP 核心引擎
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<F5>", function() require('dap').continue() end, desc = "启动/继续调试" },
      { "<F9>", function() require('dap').toggle_breakpoint() end, desc = "切换断点" },
      { "<F10>", function() require('dap').step_over() end, desc = "单步跳过" },
      { "<F11>", function() require('dap').step_into() end, desc = "单步进入" },
      { "<S-F11>", function() require('dap').step_out() end, desc = "单步跳出" },
      { "<F6>", function() require('dap').continue() end, desc = "继续执行" },
      { "<leader>db", function() require('dap').toggle_breakpoint() end, desc = "切换断点" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("断点条件: ")) end, desc = "条件断点" },
      { "<leader>dc", function() require('dap').continue() end, desc = "继续" },
      { "<leader>dr", function() require("dap").run_last() end, desc = "重运行上次调试" },
      { "<leader>dt", function() require('dap').terminate() end, desc = "终止调试" },
      { "<leader>da", function()
        require("dap").continue({
          before = function(config)
            local args_str = vim.fn.input("运行参数: ", "")
            if args_str ~= "" then
              config.args = require("dap.utils").splitstr(args_str)
            end
            return config
          end,
        })
      end, desc = "带参数运行" },
      { "<leader>dC", function() require('dap').run_to_cursor() end, desc = "运行到光标" },
      { "<leader>dg", function() require('dap').goto_() end, desc = "跳到指定行" },
      { "<leader>di", function() require('dap').step_into() end, desc = "单步进入" },
      { "<leader>dj", function() require('dap').down() end, desc = "调用栈向下" },
      { "<leader>dk", function() require('dap').up() end, desc = "调用栈向上" },
      { "<leader>do", function() require('dap').step_out() end, desc = "单步跳出" },
      { "<leader>dO", function() require('dap').step_over() end, desc = "单步跳过" },
      { "<leader>dP", function() require('dap').pause() end, desc = "暂停" },
      { "<leader>ds", function() require('dap').session() end, desc = "查看会话" },
      { "<leader>dw", function() require('dap.ui.widgets').hover() end, desc = "悬浮查看变量" },
      { "<leader>dl", function()
        require('dap').set_breakpoint(nil, nil, vim.fn.input("日志消息: "))
      end, desc = "日志断点" },
    },

    config = function()
      local dap = require('dap')
      local python_tools = require("config.python")

      -- 配置断点图标（使用 Unicode 字符）
      vim.fn.sign_define('DapBreakpoint', {
        text = '●',
        texthl = 'DiagnosticError',
        linehl = '',
        numhl = 'DiagnosticError'
      })
      vim.fn.sign_define('DapBreakpointCondition', {
        text = '◆',
        texthl = 'DiagnosticWarn',
        linehl = '',
        numhl = 'DiagnosticWarn'
      })
      vim.fn.sign_define('DapBreakpointRejected', {
        text = '✖',
        texthl = 'DiagnosticError',
        linehl = '',
        numhl = 'DiagnosticError'
      })
      vim.fn.sign_define('DapStopped', {
        text = '▶',
        texthl = 'DiagnosticInfo',
        linehl = 'Visual',
        numhl = 'DiagnosticInfo'
      })

      -- Python 调试适配器 (debugpy via Mason)
      dap.adapters.python = {
        type = "executable",
        command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
        args = { "-m", "debugpy.adapter" },
      }

      -- Python 调试配置
      dap.configurations.python = {
        {
          name = "启动当前 Python 文件",
          type = "python",
          request = "launch",
          program = "${file}",
          pythonPath = function()
            return python_tools.python_path()
          end,
          console = "integratedTerminal",
        },
        {
          name = "启动 Python 模块",
          type = "python",
          request = "launch",
          module = function()
            return vim.fn.input("模块名: ")
          end,
          pythonPath = function()
            return python_tools.python_path()
          end,
          console = "integratedTerminal",
        },
        {
          name = "启动（带参数）",
          type = "python",
          request = "launch",
          program = "${file}",
          pythonPath = function()
            return python_tools.python_path()
          end,
          args = function()
            local args_str = vim.fn.input("运行参数: ", "")
            return args_str ~= "" and require("dap.utils").splitstr(args_str) or {}
          end,
          console = "integratedTerminal",
        },
        {
          name = "附加到远程 debugpy",
          type = "python",
          request = "attach",
          connect = {
            host = "127.0.0.1",
            port = function()
              return tonumber(vim.fn.input("调试端口: ", "5678"))
            end,
          },
        },
      }

      -- Java 调试适配器配置
      dap.configurations.java = {
        {
          type = 'java',
          request = 'launch',
          name = "启动当前 Java 文件",
          mainClass = "${file}",  -- 运行当前文件
        },
        {
          type = 'java',
          request = 'launch',
          name = "启动 Java 程序（指定主类）",
          mainClass = function()
            return vim.fn.input('主类名（如 com.example.Main）: ')
          end,
        },
        {
          type = 'java',
          request = 'attach',
          name = "附加到远程 Java 进程",
          hostName = "localhost",
          port = function()
            return tonumber(vim.fn.input('调试端口: ', '5005'))
          end,
        },
      }

      -- C/C++ 调试适配器 (codelldb via Mason)
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/codelldb",
          args = { "--port", "${port}" },
        },
      }

      -- C/C++ 调试配置
      local cpp_configs = {
        {
          name = "LongMarch 调试（Debug）",
          type = "codelldb",
          request = "launch",
          program = "${workspaceFolder}/build/debug/Application/LongMarch",
          cwd = "${workspaceFolder}/build/debug/Application",
          stopOnEntry = false,
          args = {},
        },
        {
          name = "LongMarch 调试（Release）",
          type = "codelldb",
          request = "launch",
          program = "${workspaceFolder}/build/release/Application/LongMarch",
          cwd = "${workspaceFolder}/build/release/Application",
          stopOnEntry = false,
          args = {},
        },
        {
          name = "启动（选择可执行文件）",
          type = "codelldb",
          request = "launch",
          program = function()
            local build_dir = vim.fn.getcwd() .. "/build"
            return vim.fn.input("可执行文件: ", build_dir .. "/", "file")
          end,
          cwd = function()
            return vim.fn.input("工作目录: ", vim.fn.getcwd() .. "/", "file")
          end,
          stopOnEntry = false,
        },
        {
          name = "附加到进程",
          type = "codelldb",
          request = "attach",
          pid = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }
      dap.configurations.cpp = cpp_configs
      dap.configurations.c = cpp_configs

      -- 支持加载 .vscode/launch.json（处理 JSONC 注释格式）
      local vscode_ok, vscode_dap = pcall(require, "dap.ext.vscode")
      if vscode_ok then
        vscode_dap.json_decode = function(str)
          return vim.json.decode(str:gsub("//[^\n]*", ""))
        end
      end

      -- Java 调试适配器（通过 nvim-jdtls 集成）
      dap.adapters.java = function(callback)
        -- nvim-jdtls 会自动配置调试适配器
        callback({
          type = 'server',
          host = '127.0.0.1',
          port = 5005,
        })
      end
    end
  },

  -- DAP 可视化界面
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio"
    },
    keys = {
      { "<leader>du", function() require('dapui').toggle() end, desc = "切换调试界面" },
      { "<leader>de", function() require('dapui').eval() end, desc = "计算表达式", mode = {"n", "v"} },
    },

    config = function()
      local dap, dapui = require("dap"), require("dapui")

      -- 配置调试界面布局
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.4 },      -- 变量作用域
              { id = "breakpoints", size = 0.2 }, -- 断点列表
              { id = "stacks", size = 0.4 },      -- 调用栈
            },
            size = 40,
            position = "left",  -- 左侧面板
          },
          {
            elements = {
              { id = "repl", size = 0.5 },    -- 交互式控制台
              { id = "console", size = 0.5 }, -- 程序输出
            },
            size = 10,
            position = "bottom",  -- 底部面板
          },
        },
        controls = {
          enabled = true,
          element = "repl",
          icons = {
            pause = "⏸",
            play = "▶",
            step_into = "⏎",
            step_over = "⏭",
            step_out = "⏮",
            step_back = "⏪",
            run_last = "▶▶",
            terminate = "⏹",
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = "rounded",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil,
          max_value_lines = 100,
        },
      })

      -- 自动打开/关闭调试界面
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end

      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end

      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end
  },

  -- Mason 自动安装 DAP 适配器
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
    opts = {
      ensure_installed = { "codelldb", "debugpy" },
      automatic_installation = true,
    },
  },

  -- DAP 虚拟文本（在代码中显示变量值）
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
      highlight_new_as_changed = false,
      show_stop_reason = true,
      commented = false,
      only_first_definition = true,
      all_references = false,
      filter_references_pattern = '<module',
      virt_text_pos = 'eol',
      all_frames = false,
      virt_lines = false,
      virt_text_win_col = nil
    }
  }
}
