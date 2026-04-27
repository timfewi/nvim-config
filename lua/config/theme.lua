local M = {}

local themes = require 'config.themes'
local mode_path = (vim.env.HOME or '') .. '/.local/state/theme/current-mode'
local applied_mode
local applied_theme_name

local function current_mode()
  local file = io.open(mode_path, 'r')
  if not file then
    return 'dark'
  end

  local mode = file:read '*a'
  file:close()

  mode = mode:gsub('%s+', '')
  if mode == 'light' then
    return 'light'
  end

  return 'dark'
end

local function set_theme_name(name)
  assert(themes.exists(name), ('Unknown theme: %s'):format(name))

  vim.fn.mkdir(vim.fn.fnamemodify(themes.path, ':h'), 'p')

  local file = assert(io.open(themes.path, 'w'))
  file:write(name, '\n')
  file:close()
end

local function apply_theme(theme_name, mode)
  local theme = themes.get(theme_name)
  local ok, theme_module = pcall(require, theme.module)
  assert(ok, ('Failed to load theme module: %s'):format(theme.module))

  if theme.setup then
    theme_module.setup(theme.setup(mode))
  end

  vim.o.background = mode
  vim.cmd.colorscheme(theme.colorscheme)
  applied_mode = mode
  applied_theme_name = theme_name
end

local function sync_theme()
  local mode = current_mode()
  local theme_name = themes.current_name()

  if mode ~= applied_mode or theme_name ~= applied_theme_name then
    apply_theme(theme_name, mode)
  end
end

local function create_commands()
  vim.api.nvim_create_user_command('Theme', function(opts)
    if opts.args == '' then
      vim.notify(('Current theme: %s'):format(themes.current_name()))
      return
    end

    set_theme_name(opts.args)
    sync_theme()
    vim.notify(('Theme switched to %s'):format(themes.current_name()))
  end, {
    nargs = '?',
    complete = function() return themes.names() end,
    desc = 'Get or set the active Neovim theme',
    force = true,
  })

  vim.api.nvim_create_user_command('ThemeNext', function()
    local next_theme = themes.next_name(themes.current_name())
    set_theme_name(next_theme)
    sync_theme()
    vim.notify(('Theme switched to %s'):format(next_theme))
  end, {
    desc = 'Cycle to the next Neovim theme',
    force = true,
  })
end

function M.apply()
  sync_theme()
  create_commands()

  local group = vim.api.nvim_create_augroup('theme-sync', { clear = true })
  vim.api.nvim_create_autocmd({ 'FocusGained', 'VimResume' }, {
    group = group,
    callback = sync_theme,
    desc = 'Reload Neovim theme when global theme settings change',
  })
end

return M
