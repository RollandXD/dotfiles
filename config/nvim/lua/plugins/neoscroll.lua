-- ========== neoscroll.nvim - 平滑滚动插件 ==========
-- 替代 comfortable-motion.vim 的 Lua 原生插件

return {
  "karb94/neoscroll.nvim",
  event = "VeryLazy",  -- 延迟加载，提升启动速度
  config = function()
    require('neoscroll').setup({
      -- 缓动函数：quadratic（二次）、cubic（三次）、quartic（四次）、quintic（五次）
      -- 推荐 quadratic，最接近 comfortable-motion 的物理感
      easing_function = "quadratic",

      -- 隐藏光标（滚动时）
      hide_cursor = false,

      -- 性能模式（滚动时禁用语法高亮，超长文件推荐开启）
      performance_mode = false,

      -- 滚动停止时的缓冲（毫秒）
      stop_eof = true,  -- 滚动到文件末尾时停止

      -- 尊重 scrolloff 设置
      respect_scrolloff = true,

      -- 光标跟随滚动的延迟（毫秒）
      cursor_scrolls_alone = true,

      -- 滚动速度映射（默认映射）
      mappings = {
        '<C-u>', '<C-d>',  -- 半屏滚动
        '<C-b>', '<C-f>',  -- 全屏滚动
        '<C-y>', '<C-e>',  -- 单行滚动
        'zt', 'zz', 'zb',  -- 光标位置调整
      },
    })

    -- 自定义滚动速度（可选，注释掉使用默认值）
    -- local t = {}
    -- t['<C-u>'] = {'scroll', {'-vim.wo.scroll', 'true', '100'}}
    -- t['<C-d>'] = {'scroll', { 'vim.wo.scroll', 'true', '100'}}
    -- require('neoscroll.config').set_mappings(t)
  end,
}
