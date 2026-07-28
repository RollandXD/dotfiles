-- ========== Python 工程体验 ==========
-- 面向 ruff + mypy + pytest 的轻量 Python 项目流。
-- uv 项目走 `uv run`，其它项目（poetry / 裸 venv / conda）直接调 venv 里的可执行文件。

local function fs_stat(path)
  return path and (vim.uv or vim.loop).fs_stat(path) or nil
end

local function run_project_task(name, command)
  local overseer = require("overseer")
  local root = require("config.python").root()

  overseer.new_task({
    name = name,
    cmd = vim.o.shell,
    args = { vim.o.shellcmdflag, command },
    cwd = root,
    components = {
      "default",
      "unique",
    },
  }):start()
  overseer.open({ enter = false })
end

-- 把 { "pytest", "-q" } 这样的参数表拼成当前项目能真正执行的一条命令
local function tool_command(args)
  local python_tools = require("config.python")
  local root = python_tools.root()

  if fs_stat(root .. "/uv.lock") and vim.fn.executable("uv") == 1 then
    return "uv run " .. table.concat(args, " ")
  end

  local parts = { vim.fn.shellescape(python_tools.executable(args[1])) }
  vim.list_extend(parts, vim.list_slice(args, 2))
  return table.concat(parts, " ")
end

local function run_tool(name, args)
  run_project_task(name, tool_command(args))
end

-- mypy 目标：src-layout 用 src/，否则退回当前目录
local function mypy_target()
  local root = require("config.python").root()
  return fs_stat(root .. "/src") and "src" or "."
end

-- 提交前全套检查：格式检查 → lint → 类型 → 测试，任一失败即中断
local function precommit_command()
  return table.concat({
    tool_command({ "ruff", "format", "--check", "." }),
    tool_command({ "ruff", "check", "." }),
    tool_command({ "mypy", mypy_target() }),
    tool_command({ "pytest" }),
  }, " && ")
end

return {
  {
    "linux-cultist/venv-selector.nvim",
    ft = "python",
    cmd = { "VenvSelect", "VenvSelectLog", "VenvSelectCache" },
    keys = {
      { "<leader>pv", "<cmd>VenvSelect<cr>", desc = "选择 Python 虚拟环境" },
    },
    opts = {
      options = {
        picker = "snacks",
        notify_user_on_venv_activation = true,
        activate_venv_in_terminal = true,
        set_environment_variables = true,
      },
      search = {
        workspace = {
          command = "$FD '/bin/python$' '$WORKSPACE_PATH' --full-path --color never -I -a -L -E .git/ -E site-packages/",
        },
      },
    },
  },

  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
    },
    cmd = "Neotest",
    keys = {
      { "<leader>pt", function() require("neotest").run.run() end, desc = "运行当前 Python 测试" },
      { "<leader>pT", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "运行当前文件测试" },
      { "<leader>pl", function() require("neotest").run.run_last() end, desc = "重跑上次测试" },
      { "<leader>pd", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "调试当前测试" },
      { "<leader>ps", function() require("neotest").summary.toggle() end, desc = "测试结构面板" },
      { "<leader>pO", function() require("neotest").output_panel.toggle() end, desc = "测试输出面板" },
    },
    opts = function()
      local python_tools = require("config.python")

      return {
        adapters = {
          require("neotest-python")({
            runner = "pytest",
            python = function()
              return python_tools.python_path()
            end,
            dap = {
              justMyCode = false,
            },
          }),
        },
      }
    end,
  },

  {
    "stevearc/overseer.nvim",
    cmd = {
      "OverseerRun",
      "OverseerToggle",
      "OverseerOpen",
      "OverseerClose",
      "OverseerQuickAction",
      "PythonCheck",
      "PythonPreCommit",
    },
    keys = {
      { "<leader>po", "<cmd>OverseerToggle<cr>", desc = "项目任务面板" },
      { "<leader>pa", function() run_tool("pytest: 全部测试", { "pytest" }) end, desc = "运行全部测试" },
      { "<leader>pm", function() run_tool("mypy: 类型检查", { "mypy", mypy_target() }) end, desc = "运行 mypy" },
      { "<leader>pr", function() run_tool("ruff: 检查", { "ruff", "check", "." }) end, desc = "Ruff 检查" },
      { "<leader>pR", function() run_tool("ruff: 自动修复", { "ruff", "check", "--fix", "." }) end, desc = "Ruff 自动修复" },
      { "<leader>pf", function() run_tool("ruff: 格式检查", { "ruff", "format", "--check", "." }) end, desc = "Ruff 格式检查" },
      { "<leader>pc", function()
        run_project_task("Python: 提交前检查", precommit_command())
      end, desc = "运行提交前检查" },
      { "<leader>pC", function() run_tool("pre-commit: 全量", { "pre-commit", "run", "--all-files" }) end, desc = "运行 pre-commit 全量检查" },
    },
    opts = {
      strategy = {
        "terminal",
        direction = "bottom",
        size = 15,
      },
    },
    config = function(_, opts)
      local overseer = require("overseer")
      overseer.setup(opts)

      vim.api.nvim_create_user_command("PythonCheck", function()
        run_project_task("Python: 提交前检查", precommit_command())
      end, { desc = "本地提交前检查：ruff format --check + ruff check + mypy + pytest" })

      vim.api.nvim_create_user_command("PythonPreCommit", function()
        run_tool("pre-commit: 全量", { "pre-commit", "run", "--all-files" })
      end, { desc = "运行 pre-commit run --all-files" })
    end,
  },
}
