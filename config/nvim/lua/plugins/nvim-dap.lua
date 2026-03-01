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
      { "<leader>dc", function() require('dap').continue() end, desc = "继续" },
      { "<leader>dt", function() require('dap').terminate() end, desc = "终止调试" },
    },

    config = function()
      local dap = require('dap')

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
