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

    statusline.section_lsp = function()
      local clients = vim.lsp.get_clients { bufnr = vim.api.nvim_get_current_buf() }
      if #clients == 0 then return '' end

      local names = {}
      for _, client in ipairs(clients) do
        if client.name ~= 'null-ls' then
          table.insert(names, client.name)
        end
      end
      if #names == 0 then return '' end

      local buf = vim.api.nvim_get_current_buf()
      local errors = #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.ERROR })
      local warnings = #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.WARN })

      local parts = { table.concat(names, ',') }
      if errors > 0 then table.insert(parts, 'E:' .. errors) end
      if warnings > 0 then table.insert(parts, 'W:' .. warnings) end

      return table.concat(parts, ' ')
    end
  end,
})

table.insert(specs, {
  'stevearc/dressing.nvim',
  event = 'VeryLazy',
  opts = {
    input = {
      enabled = true,
      default_prompt = 'Input:',
      trim_input = true,
    },
    select = {
      enabled = true,
      backend = { 'telescope', 'builtin' },
    },
  },
})

return specs
