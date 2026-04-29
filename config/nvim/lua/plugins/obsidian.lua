-- ========== obsidian.nvim - Obsidian 笔记集成 ==========
-- 使用社区维护版 obsidian-nvim/obsidian.nvim

return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",       -- 使用最新稳定版
  lazy = true,
  ft = "markdown",     -- 只在打开 Markdown 文件时加载
  dependencies = {
    "nvim-lua/plenary.nvim",       -- 必需
  },
  opts = {
    -- 禁用旧的 :ObsidianXxx 命令，改用新的 :Obsidian xxx 子命令（4.0 将彻底移除旧命令）
    legacy_commands = false,

    -- Vault 配置
    workspaces = {
      {
        name = "personal",
        path = "~/Documents/personal_obsidian_vault/Obsidian Vault",
      },
    },

    -- 补全设置（blink.cmp 可通过 source 集成，也可禁用内置 cmp）
    completion = {
      nvim_cmp = false,   -- 已迁移至 blink.cmp，禁用旧的 nvim-cmp 集成
      min_chars = 2,      -- 最少输入 2 个字符触发补全
      blink = true,       -- 启用 blink.cmp 集成
    },

    -- 新笔记设置
    new_notes_location = "notes_subdir",
    notes_subdir = "Notes",

    -- 笔记 ID 格式
    note_id_func = function(title)
      -- 直接用标题作为文件名
      if title ~= nil then
        return title
      end
      -- 无标题时用时间戳
      return tostring(os.time())
    end,

    -- 模版
    templates = {
      folder = "Templates",
    },

    -- UI 设置（不与 render-markdown.nvim 冲突）
    ui = {
      enable = false,   -- 禁用自带 UI，用你已有的 render-markdown.nvim
    },
  },
  keys = {
    { "<leader>no", "<cmd>Obsidian open<cr>", desc = "在 Obsidian 中打开" },
    { "<leader>nn", "<cmd>Obsidian new<cr>", desc = "新建笔记" },
    { "<leader>ns", "<cmd>Obsidian search<cr>", desc = "搜索笔记" },
    { "<leader>nq", "<cmd>Obsidian quick_switch<cr>", desc = "快速切换笔记" },
    { "<leader>nl", "<cmd>Obsidian links<cr>", desc = "查看链接" },
    { "<leader>nb", "<cmd>Obsidian backlinks<cr>", desc = "查看反向链接" },
    { "<leader>nt", "<cmd>Obsidian tags<cr>", desc = "搜索标签" },
    { "<leader>nd", "<cmd>Obsidian dailies<cr>", desc = "每日笔记" },
  },
}
