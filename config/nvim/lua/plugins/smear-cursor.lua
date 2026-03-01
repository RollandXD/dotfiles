-- ========== smear-cursor.nvim - 光标拖尾特效 ==========
-- 光标移动时产生"涂抹拖尾"视觉效果

return {
  "sphamba/smear-cursor.nvim",
  event = "VeryLazy",
  opts = {
    -- 光标颜色（浅米色）
    cursor_color = "#d3cdc3",

    -- 普通光标颜色（可选）
    -- normal_bg = "#282828",

    -- 拖尾硬度（0-1，越小拖尾越长）
    stiffness = 0.8,

    -- 拖尾末端硬度（0-1）
    trailing_stiffness = 0.5,

    -- 拖尾衰减速度（0-1，越大衰减越快）
    trailing_exponent = 0.1,

    -- 停止动画的最小距离
    distance_stop_animating = 0.5,

    -- 隐藏目标光标（tmux 兼容性 hack）
    hide_target_hack = false,
  },
}
