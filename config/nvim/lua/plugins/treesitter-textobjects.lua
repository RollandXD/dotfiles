return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = "VeryLazy",
  config = function()
    -- 新版 nvim-treesitter 不再使用 nvim-treesitter.configs
    -- textobjects 通过 vim.keymap.set + ts_repeat_move 手动配置

    local ts_select = require("nvim-treesitter-textobjects.select")
    local ts_move = require("nvim-treesitter-textobjects.move")
    local ts_swap = require("nvim-treesitter-textobjects.swap")

    -- 文本对象选择
    local select_keymaps = {
      ["af"] = { query = "@function.outer", desc = "函数（含签名）" },
      ["if"] = { query = "@function.inner", desc = "函数体" },
      ["ac"] = { query = "@class.outer", desc = "类（含定义）" },
      ["ic"] = { query = "@class.inner", desc = "类体" },
      ["aa"] = { query = "@parameter.outer", desc = "参数（含逗号）" },
      ["ia"] = { query = "@parameter.inner", desc = "参数值" },
    }

    for key, mapping in pairs(select_keymaps) do
      vim.keymap.set({ "x", "o" }, key, function()
        ts_select.select_textobject(mapping.query, "textobjects")
      end, { desc = mapping.desc })
    end

    -- 移动：跳转到下一个/上一个函数/类
    local move_keymaps = {
      ["]f"] = { query = "@function.outer", desc = "下一个函数", fn = "goto_next_start" },
      ["]c"] = { query = "@class.outer", desc = "下一个类", fn = "goto_next_start" },
      ["[f"] = { query = "@function.outer", desc = "上一个函数", fn = "goto_previous_start" },
      ["[c"] = { query = "@class.outer", desc = "上一个类", fn = "goto_previous_start" },
    }

    for key, mapping in pairs(move_keymaps) do
      vim.keymap.set({ "n", "x", "o" }, key, function()
        ts_move[mapping.fn](mapping.query, "textobjects")
      end, { desc = mapping.desc })
    end

    -- 交换参数
    vim.keymap.set("n", "<leader>xp", function()
      ts_swap.swap_next("@parameter.inner")
    end, { desc = "交换参数（向后）" })

    vim.keymap.set("n", "<leader>xP", function()
      ts_swap.swap_previous("@parameter.inner")
    end, { desc = "交换参数（向前）" })
  end,
}
