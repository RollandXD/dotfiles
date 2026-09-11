-- ========== 智能 LSP hover ==========
-- Python 优先使用 Pyright 的类型感知文档；只有 Pyright 没有说明正文时，
-- 才回退到 Jedi 的运行时 docstring。其他语言继续使用 Neovim 原生 hover。

local M = {}

local request_generation = {}

local function client_by_name(bufnr, name)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client.name == name then
      return client
    end
  end
end

local function hover_lines(result)
  if not (result and result.contents) then
    return
  end

  local contents = result.contents
  if type(contents) == "table" and contents.kind == "plaintext" then
    local lines = vim.split(contents.value or "", "\n", { trimempty = true })
    return not vim.tbl_isempty(lines) and lines or nil, "plaintext"
  end

  local lines = vim.lsp.util.convert_input_to_markdown_lines(contents)
  return not vim.tbl_isempty(lines) and lines or nil, "markdown"
end

local function has_prose(result)
  local lines = hover_lines(result)
  if not lines then
    return false
  end

  local in_code_fence = false
  for _, line in ipairs(lines) do
    local text = vim.trim(line)
    if text:match("^```") then
      in_code_fence = not in_code_fence
    elseif not in_code_fence
        and text ~= ""
        and not text:match("^[-*_ ]+$")
        and not text:match("^%*%*Full name:%*%*")
        and not text:match("^Full name:") then
      return true
    end
  end

  return false
end

local function request_is_current(request)
  if request_generation[request.bufnr] ~= request.generation then
    return false
  end
  if not (vim.api.nvim_buf_is_valid(request.bufnr) and vim.api.nvim_win_is_valid(request.winid)) then
    return false
  end
  if vim.api.nvim_get_current_win() ~= request.winid or vim.api.nvim_get_current_buf() ~= request.bufnr then
    return false
  end
  return vim.deep_equal(vim.api.nvim_win_get_cursor(request.winid), request.cursor)
end

local function show_hover(result, request)
  if not request_is_current(request) then
    return
  end

  local lines, syntax = hover_lines(result)
  if not lines then
    vim.notify("没有可用的悬浮文档", vim.log.levels.INFO)
    return
  end

  vim.lsp.util.open_floating_preview(lines, syntax, {
    border = "rounded",
    focus_id = "textDocument/hover",
  })
end

local function request_hover(client, request, callback)
  local params = vim.lsp.util.make_position_params(request.winid, client.offset_encoding)
  local sent = client:request("textDocument/hover", params, function(err, result)
    vim.schedule(function()
      if request_is_current(request) then
        callback(err, result)
      end
    end)
  end, request.bufnr)

  if not sent then
    vim.schedule(function()
      if request_is_current(request) then
        callback({ message = client.name .. " 无法发送 hover 请求" })
      end
    end)
  end
end

local function show_jedi_or_primary(jedi, primary, request)
  if not jedi then
    if primary then
      show_hover(primary, request)
    else
      vim.notify("没有可用的悬浮文档", vim.log.levels.INFO)
    end
    return
  end

  request_hover(jedi, request, function(err, result)
    local secondary = not err and hover_lines(result) and result or nil
    if secondary and has_prose(secondary) then
      show_hover(secondary, request)
    elseif primary then
      show_hover(primary, request)
    elseif secondary then
      show_hover(secondary, request)
    else
      vim.notify("没有可用的悬浮文档", vim.log.levels.INFO)
    end
  end)
end

function M.hover()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype ~= "python" then
    vim.lsp.buf.hover()
    return
  end

  local pyright = client_by_name(bufnr, "pyright")
  local jedi = client_by_name(bufnr, "jedi_language_server")
  if not (pyright or jedi) then
    vim.lsp.buf.hover()
    return
  end

  local generation = (request_generation[bufnr] or 0) + 1
  request_generation[bufnr] = generation
  local request = {
    bufnr = bufnr,
    winid = vim.api.nvim_get_current_win(),
    cursor = vim.api.nvim_win_get_cursor(0),
    generation = generation,
  }

  if not pyright then
    show_jedi_or_primary(jedi, nil, request)
    return
  end

  request_hover(pyright, request, function(err, result)
    local primary = not err and hover_lines(result) and result or nil
    if primary and has_prose(primary) then
      show_hover(primary, request)
    else
      show_jedi_or_primary(jedi, primary, request)
    end
  end)
end

return M
