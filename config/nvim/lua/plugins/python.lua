-- ========== Python 工程体验 ==========
-- 面向 uv + ruff + mypy + pytest 的轻量 Python 项目流。

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

local function run_uv(name, args)
  run_project_task(name, "uv run " .. table.concat(args, " "))
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
      "PhosphorCheck",
      "PhosphorPreCommit",
    },
    keys = {
      { "<leader>po", "<cmd>OverseerToggle<cr>", desc = "项目任务面板" },
      { "<leader>pa", function() run_uv("pytest: 全部测试", { "pytest" }) end, desc = "运行全部测试" },
      { "<leader>pm", function() run_uv("mypy: src", { "mypy", "src" }) end, desc = "运行 mypy src" },
      { "<leader>pr", function() run_uv("ruff: 检查", { "ruff", "check", "." }) end, desc = "Ruff 检查" },
      { "<leader>pR", function() run_uv("ruff: 自动修复", { "ruff", "check", "--fix", "." }) end, desc = "Ruff 自动修复" },
      { "<leader>pf", function() run_uv("ruff: 格式检查", { "ruff", "format", "--check", "." }) end, desc = "Ruff 格式检查" },
      { "<leader>pc", function()
        run_project_task(
          "Phosphor: 提交前检查",
          "uv run ruff format --check . && uv run ruff check . && uv run mypy src && uv run pytest"
        )
      end, desc = "运行提交前检查" },
      { "<leader>pC", function() run_uv("pre-commit: 全量", { "pre-commit", "run", "--all-files" }) end, desc = "运行 pre-commit 全量检查" },
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

      vim.api.nvim_create_user_command("PhosphorCheck", function()
        run_project_task(
          "Phosphor: 提交前检查",
          "uv run ruff format --check . && uv run ruff check . && uv run mypy src && uv run pytest"
        )
      end, { desc = "运行 Phosphor 本地提交前检查" })

      vim.api.nvim_create_user_command("PhosphorPreCommit", function()
        run_uv("pre-commit: 全量", { "pre-commit", "run", "--all-files" })
      end, { desc = "运行 uv run pre-commit run --all-files" })
    end,
  },
}
