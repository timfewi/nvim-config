local themes = require 'config.themes'
local specs = themes.plugin_specs()

table.insert(specs, {
  'folke/todo-comments.nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = { signs = false },
})

table.insert(specs, {
  'nvim-mini/mini.nvim',
  config = function()
    require('mini.ai').setup {
      mappings = {
        around_next = 'aa',
        inside_next = 'ii',
      },
      n_lines = 500,
    }

    require('mini.surround').setup()

    local statusline = require 'mini.statusline'
    statusline.setup { use_icons = vim.g.have_nerd_font }
    statusline.section_location = function() return '%2l:%-2v' end
  end,
})

return specs
