-- 原生选区直接传给小窗，不使用 yank，不改写寄存器或系统剪贴板。
local M = {}

function M.selected_text()
  local mode = vim.fn.mode()
  if mode == 'v' or mode == 'V' or mode == '\22' then
    local lines = vim.fn.getregion(vim.fn.getpos('v'), vim.fn.getpos('.'), {
      type = mode,
      exclusive = vim.o.selection == 'exclusive',
    })
    return table.concat(lines, '\n')
  end
  return vim.fn.expand('<cword>')
end

function M.lookup()
  local text = M.selected_text()
  if text == '' then
    vim.notify('没有可查询的英文选区或单词', vim.log.levels.INFO)
    return
  end
  local command = vim.fn.exepath('english-lookup')
  if command == '' then
    vim.notify('找不到 english-lookup：请先运行 dotfiles 的 arch/setup.sh', vim.log.levels.ERROR)
    return
  end
  vim.system({ command, 'stdin' }, { stdin = text, text = true, detach = true }, function(result)
    if result.code ~= 0 then
      vim.schedule(function()
        vim.notify('英文查询小窗启动失败；运行 english-lookup open 查看报错', vim.log.levels.ERROR)
      end)
    end
  end)
end

function M.setup()
  vim.keymap.set({ 'n', 'x' }, '<leader>te', M.lookup, { desc = '英文随查：选区或光标下的词' })
  vim.api.nvim_create_user_command('EnglishLookup', M.lookup, {})
end

return M
