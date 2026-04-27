local M = {}

local mode_path = (vim.env.HOME or '') .. '/.local/state/theme/current-mode'
local applied_mode

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

local function apply_mode(mode)
  require('tokyonight').setup {
    style = mode == 'light' and 'day' or 'night',
    styles = {
      comments = { italic = false },
    },
  }

  vim.o.background = mode
  vim.cmd.colorscheme 'tokyonight'
  applied_mode = mode
end

function M.apply()
  apply_mode(current_mode())

  local group = vim.api.nvim_create_augroup('theme-sync', { clear = true })
  vim.api.nvim_create_autocmd({ 'FocusGained', 'VimResume' }, {
    group = group,
    callback = function()
      local mode = current_mode()
      if mode ~= applied_mode then
        apply_mode(mode)
      end
    end,
  })
end

return M
