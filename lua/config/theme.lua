local M = {}

function M.apply()
  require('tokyonight').setup {
    styles = {
      comments = { italic = false },
    },
  }

  vim.cmd.colorscheme 'tokyonight-night'
end

return M
