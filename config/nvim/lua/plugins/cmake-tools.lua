local cmake_opts = {
  cmake_use_preset = true,
  cmake_build_directory = "build",
  cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" },
  cmake_executor = {
    name = "quickfix",
    opts = {
      show = "always",
      size = 10,
    },
  },
  cmake_runner = {
    name = "terminal",
    opts = {
      split_direction = "horizontal",
      split_size = 10,
      focus = true,
    },
  },
}

local synced_root = nil

local function path_exists(path, kind)
  local uv = vim.uv or vim.loop
  local stat = uv.fs_stat(path)
  if not stat then
    return false
  end

  if kind == nil then
    return true
  end

  return stat.type == kind
end

local function unload_cmake_tools()
  for name in pairs(package.loaded) do
    if name == "cmake-tools" or name:match("^cmake%-tools%.") then
      package.loaded[name] = nil
    end
  end
end

local function normalized(path)
  return vim.fs.normalize(path)
end

local function contains(text, pattern)
  return type(text) == "string" and text:find(pattern, 1, true) ~= nil
end

local function session_cache_path(root)
  local cleaned = root:gsub("/", ""):gsub("\\", ""):gsub(":", "")
  return vim.fs.joinpath(vim.fn.expand("~/.cache/cmake_tools_nvim"), cleaned .. ".lua")
end

local function read_session(path)
  if not path_exists(path, "file") then
    return nil
  end

  local ok, data = pcall(dofile, path)
  if ok and type(data) == "table" then
    return data
  end

  return nil
end

local function write_session(path, data)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  local file = io.open(path, "w")
  if not file then
    return
  end

  file:write("return " .. vim.inspect(data))
  file:close()
end

local function ensure_preset_session(root)
  local has_presets = path_exists(vim.fs.joinpath(root, "CMakePresets.json"), "file")
    or path_exists(vim.fs.joinpath(root, "cmake-presets.json"), "file")
  if not has_presets then
    return
  end

  local path = session_cache_path(root)
  local session = read_session(path) or {}
  local debug_build_dir = vim.fs.joinpath(root, "build", "debug")
  local legacy_build_dir = vim.fs.joinpath(root, "build")
  local changed = false

  if session.configure_preset == nil then
    session.configure_preset = "debug"
    changed = true
  end

  if session.build_preset == nil then
    session.build_preset = "debug"
    changed = true
  end

  if session.build_type == nil then
    session.build_type = "Debug"
    changed = true
  end

  if session.cwd ~= root then
    session.cwd = root
    changed = true
  end

  local base_settings = session.base_settings or {}
  if base_settings.use_preset ~= true then
    base_settings.use_preset = true
    changed = true
  end
  if base_settings.show_disabled_build_presets == nil then
    base_settings.show_disabled_build_presets = true
    changed = true
  end
  if base_settings.generate_options == nil then
    base_settings.generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" }
    changed = true
  end
  if base_settings.build_options == nil then
    base_settings.build_options = {}
    changed = true
  end
  if base_settings.env == nil then
    base_settings.env = {}
    changed = true
  end
  if base_settings.working_dir == nil then
    base_settings.working_dir = "${dir.binary}"
    changed = true
  end
  if
    base_settings.build_dir == nil
    or normalized(base_settings.build_dir) == normalized(legacy_build_dir)
    or contains(base_settings.build_dir, "${sourceDir}")
  then
    base_settings.build_dir = debug_build_dir
    changed = true
  end

  if
    session.build_directory == nil
    or normalized(session.build_directory) == normalized(legacy_build_dir)
    or contains(session.build_directory, "${sourceDir}")
  then
    session.build_directory = debug_build_dir
    changed = true
  end

  session.base_settings = base_settings

  if changed then
    write_session(path, session)
  end
end

local function find_cmake_root(bufnr)
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == "" then
    return nil
  end

  local start = vim.fs.dirname(vim.fs.normalize(file))
  local git_dir = vim.fs.find(".git", { path = start, upward = true, type = "directory" })[1]
  if git_dir then
    local git_root = vim.fs.dirname(git_dir)
    if path_exists(vim.fs.joinpath(git_root, "CMakeLists.txt"), "file") then
      return git_root
    end
    if path_exists(vim.fs.joinpath(git_root, "CMakePresets.json"), "file") then
      return git_root
    end
    if path_exists(vim.fs.joinpath(git_root, "cmake-presets.json"), "file") then
      return git_root
    end
  end

  local preset = vim.fs.find({ "CMakePresets.json", "cmake-presets.json" }, {
    path = start,
    upward = true,
    type = "file",
  })[1]
  if preset then
    return vim.fs.dirname(preset)
  end

  local cmakelists = vim.fs.find("CMakeLists.txt", { path = start, upward = true, type = "file" })[1]
  if cmakelists then
    return vim.fs.dirname(cmakelists)
  end

  return nil
end

local function ensure_cmake_context()
  local root = find_cmake_root(0)
  if not root then
    vim.notify("当前 buffer 不在 CMake 项目里，无法执行 CMake 命令", vim.log.levels.ERROR)
    return nil
  end

  if (vim.uv or vim.loop).cwd() ~= root then
    vim.cmd.cd(vim.fn.fnameescape(root))
    synced_root = nil
  end

  ensure_preset_session(root)

  if synced_root ~= root then
    unload_cmake_tools()
    local cmake = require("cmake-tools")
    cmake.setup(vim.deepcopy(cmake_opts))
    synced_root = root
    return cmake
  end

  return require("cmake-tools")
end

local function create_cmake_command(name, fn, opts)
  vim.api.nvim_create_user_command(name, function(cmd_opts)
    local cmake = ensure_cmake_context()
    if not cmake then
      return
    end

    fn(cmake, cmd_opts or {})
  end, opts)
end

return {
  "Civitasv/cmake-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  ft = { "cmake", "cpp", "c" },
  config = function()
    create_cmake_command("CMakeConfigure", function(cmake_tools, cmd_opts)
      cmake_tools.generate(cmd_opts)
    end, {
      nargs = "*",
      bang = true,
      desc = "CMake 配置",
    })

    create_cmake_command("CMakeProjectBuild", function(cmake_tools, cmd_opts)
      cmake_tools.build(cmd_opts)
    end, {
      nargs = "*",
      bang = true,
      desc = "在项目根目录执行 CMake 构建",
    })

    create_cmake_command("CMakeProjectRun", function(cmake_tools, cmd_opts)
      cmake_tools.run(cmd_opts)
    end, {
      nargs = "*",
      desc = "在项目根目录运行 CMake 目标",
    })

    create_cmake_command("CMakeProjectSelectBuildTarget", function(cmake_tools)
      cmake_tools.select_build_target(true)
    end, {
      nargs = 0,
      desc = "选择 CMake 构建目标",
    })

    create_cmake_command("CMakeProjectSelectConfigurePreset", function(cmake_tools)
      cmake_tools.select_configure_preset()
    end, {
      nargs = 0,
      desc = "选择 CMake 配置预设",
    })

    create_cmake_command("CMakeProjectSelectBuildPreset", function(cmake_tools)
      cmake_tools.select_build_preset()
    end, {
      nargs = 0,
      desc = "选择 CMake 构建预设",
    })

    vim.api.nvim_create_user_command("CMakeStop", function()
      local cmake = require("cmake-tools")
      cmake.stop_executor()
      cmake.stop_runner()
    end, {
      nargs = 0,
      desc = "停止 CMake 任务",
    })
  end,
  keys = {
    { "<leader>cc", "<cmd>CMakeConfigure<cr>", desc = "CMake 配置" },
    { "<leader>cb", "<cmd>CMakeProjectBuild<cr>", desc = "CMake 构建" },
    { "<leader>cr", "<cmd>CMakeProjectRun<cr>", desc = "运行 CMake 目标" },
    { "<leader>ct", "<cmd>CMakeProjectSelectBuildTarget<cr>", desc = "选择 CMake 构建目标" },
    { "<leader>cx", "<cmd>CMakeProjectSelectConfigurePreset<cr>", desc = "选择 CMake 配置预设" },
    { "<leader>cp", "<cmd>CMakeProjectSelectBuildPreset<cr>", desc = "选择 CMake 构建预设" },
    { "<leader>cs", "<cmd>CMakeStop<cr>", desc = "停止 CMake 任务" },
  },
}
