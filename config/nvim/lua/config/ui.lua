local M = {}

M.special_filetypes = {
  ["snacks_picker_input"] = true,
  ["checkhealth"] = true,
  ["help"] = true,
  ["lazy"] = true,
  ["mason"] = true,
  ["snacks_explorer"] = true,
  ["neominimap"] = true,
  ["qf"] = true,
}

M.special_buftypes = {
  help = true,
  nofile = true,
  prompt = true,
  quickfix = true,
  terminal = true,
}

function M.is_utility_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return true
  end

  local filetype = vim.bo[bufnr].filetype
  local buftype = vim.bo[bufnr].buftype

  return M.special_filetypes[filetype] or M.special_buftypes[buftype] or false
end

function M.is_real_editor_window(winid)
  if not (winid and vim.api.nvim_win_is_valid(winid)) then
    return false
  end

  local config = vim.api.nvim_win_get_config(winid)
  if config.relative ~= "" then
    return false
  end

  return not M.is_utility_buffer(vim.api.nvim_win_get_buf(winid))
end

function M.editor_window_count(tabpage)
  local count = 0
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(tabpage or 0)) do
    if M.is_real_editor_window(winid) then
      count = count + 1
    end
  end
  return count
end

function M.is_listed_file_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  if not vim.bo[bufnr].buflisted then
    return false
  end

  if M.is_utility_buffer(bufnr) then
    return false
  end

  return vim.api.nvim_buf_get_name(bufnr) ~= ""
end

function M.special_filetype_list()
  return vim.tbl_keys(M.special_filetypes)
end

function M.lsp_client_label(bufnr)
  local names = {}

  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr or 0 })) do
    if client.name ~= "null-ls" then
      table.insert(names, client.name)
    end
  end

  if #names == 0 then
    return "无 LSP"
  end

  table.sort(names)
  return "LSP " .. table.concat(names, ",")
end

return M
