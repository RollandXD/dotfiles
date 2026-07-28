-- ========== Python 项目辅助 ==========
-- 统一处理 src-layout / uv / .venv 项目的 root、解释器和工具路径。

local M = {}

local root_markers = {
  "pyproject.toml",
  "uv.lock",
  "setup.py",
  "setup.cfg",
  "requirements.txt",
  ".git",
}

local function path_exists(path)
  return path and (vim.uv or vim.loop).fs_stat(path) ~= nil
end

local function dirname(path)
  return vim.fs.dirname(path)
end

local function start_path(bufnr)
  bufnr = bufnr or 0
  local name = vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_get_name(bufnr) or ""
  if name ~= "" then
    return path_exists(name) and name or dirname(name)
  end
  return (vim.uv or vim.loop).cwd()
end

-- root 查找会向上遍历目录，而 BufEnter 每次切 buffer 都会触发，
-- 因此按 buffer 名缓存结果，避免重复的文件系统调用。
local root_cache = {}

function M.root(bufnr)
  local start = start_path(bufnr)
  local cached = root_cache[start]
  if cached then
    return cached
  end

  local found = vim.fs.root(start, root_markers) or (vim.uv or vim.loop).cwd()
  root_cache[start] = found
  return found
end

function M.venv(root)
  root = root or M.root()
  local project_venv = root and (root .. "/.venv") or nil
  if path_exists(project_venv .. "/bin/python") then
    return project_venv
  end
  if vim.env.VIRTUAL_ENV and path_exists(vim.env.VIRTUAL_ENV .. "/bin/python") then
    return vim.env.VIRTUAL_ENV
  end
end

function M.bin_dir(root)
  local venv = M.venv(root)
  return venv and (venv .. "/bin") or nil
end

function M.executable(name, bufnr)
  local root = M.root(bufnr)
  local bin = M.bin_dir(root)
  local local_exe = bin and (bin .. "/" .. name) or nil
  if vim.fn.executable(local_exe or "") == 1 then
    return local_exe
  end

  local mason_exe = vim.fn.stdpath("data") .. "/mason/bin/" .. name
  if vim.fn.executable(mason_exe) == 1 then
    return mason_exe
  end

  local path_exe = vim.fn.exepath(name)
  return path_exe ~= "" and path_exe or name
end

function M.python_path(root)
  root = root or M.root()
  local bin = M.bin_dir(root)
  if bin and vim.fn.executable(bin .. "/python") == 1 then
    return bin .. "/python"
  end
  return M.executable("python")
end

function M.env(bufnr)
  local root = M.root(bufnr)
  local bin = M.bin_dir(root)
  if not bin then
    return {}
  end

  return {
    PATH = bin .. ":" .. (vim.env.PATH or ""),
    VIRTUAL_ENV = dirname(bin),
  }
end

-- 上一次注入 PATH 的 venv bin 目录。切项目时必须先撤掉它，
-- 否则多个项目的 .venv/bin 会在 PATH 里堆积，裸 `python` / `pytest`
-- 会解析到先前那个项目，和 VIRTUAL_ENV 指向的环境互相矛盾。
local injected_bin = nil

local function remove_from_path(bin)
  if not bin then
    return
  end

  local kept = vim.tbl_filter(function(entry)
    return entry ~= bin
  end, vim.split(vim.env.PATH or "", ":", { plain = true }))

  vim.env.PATH = table.concat(kept, ":")
end

function M.activate_project_venv(bufnr)
  local env = M.env(bufnr)
  if not env.VIRTUAL_ENV then
    return
  end

  local bin = env.VIRTUAL_ENV .. "/bin"
  if injected_bin == bin then
    return
  end

  remove_from_path(injected_bin)
  vim.env.VIRTUAL_ENV = env.VIRTUAL_ENV
  vim.env.PATH = bin .. ":" .. (vim.env.PATH or "")
  injected_bin = bin
end

return M
