-- ========== nvim-autopairs - 自动补全括号 ==========
-- 自动补全 ()、[]、{}、""、'' 等

return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  config = function()
    local npairs = require("nvim-autopairs")
    npairs.setup({
      -- 启用 treesitter 检查（需要先安装 nvim-treesitter）
      check_ts = true,
      ts_config = {
        lua = { "string" },  -- 在 lua 字符串中不自动配对
        javascript = { "template_string" },
      },

      -- 启用括号行检查（修复回车展开）
      enable_check_bracket_line = true,

      -- 忽略下一个字符的规则
      ignored_next_char = "[%w%.]",

      -- 启用快速换行
      fast_wrap = {
        map = "<M-e>",  -- Alt+e 快速包裹
        chars = { "{", "[", "(", '"', "'" },
        pattern = [=[[%'%"%>%]%)%}%,]]=],
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "Search",
        highlight_grey = "Comment",
      },
    })
  end,
}
