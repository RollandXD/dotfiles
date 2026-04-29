return {
  -- 核心引擎：连接数据库、执行 SQL
  {
    "tpope/vim-dadbod",
    cmd = "DB",
  },

  -- UI 界面：左侧数据库目录树
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      "tpope/vim-dadbod",
      "kristijanhusak/vim-dadbod-completion",
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection" },
    keys = {
      { "<leader>D", "<cmd>DBUIToggle<cr>", desc = "Toggle Database UI" },
    },
    init = function()
      -- 数据库 UI 配置
      vim.g.db_ui_use_nerd_font_icons = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
      vim.g.db_ui_execute_on_save = 0

      -- 保存查询的目录
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui_queries"
    end,
  },

  -- 自动补全：在 SQL 文件中补全表名、列名
  -- 补全源已在 blink-cmp.lua 中通过 per_filetype + dadbod provider 注册
  {
    "kristijanhusak/vim-dadbod-completion",
    ft = { "sql", "mysql", "plsql" },
  },
}
