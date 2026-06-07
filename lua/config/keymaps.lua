vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open line diagnostics' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic location list' })
vim.keymap.set('n', '[d', function() vim.diagnostic.jump { count = -1, float = true } end, { desc = 'Previous [D]iagnostic' })
vim.keymap.set('n', ']d', function() vim.diagnostic.jump { count = 1, float = true } end, { desc = 'Next [D]iagnostic' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '-', function()
  local dir = vim.fn.expand '%:p:h'
  if dir == '' then dir = vim.fn.getcwd() end
  vim.cmd('edit ' .. vim.fn.fnameescape(dir))
end, { desc = 'Open parent directory' })
vim.keymap.set('n', '<leader>bb', '<cmd>buffer #<CR>', { desc = 'Switch to previous [B]uffer' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<leader>td', function()
  local current = vim.diagnostic.config()
  if current.virtual_text then
    vim.diagnostic.config { virtual_text = false, virtual_lines = { current_line = true } }
  else
    vim.diagnostic.config { virtual_text = { prefix = '●', source = 'if_many', spacing = 2 }, virtual_lines = false }
  end
end, { desc = '[T]oggle [D]iagnostic display' })

vim.keymap.set('n', '<leader>xx', '<cmd>Trouble<CR>', { desc = 'Trouble: Toggle' })
vim.keymap.set('n', '<leader>xw', '<cmd>Trouble diagnostics filter.buf=0<CR>', { desc = 'Trouble: Workspace diagnostics' })
vim.keymap.set('n', '<leader>xd', '<cmd>Trouble diagnostics<CR>', { desc = 'Trouble: Document diagnostics' })
vim.keymap.set('n', '<leader>xl', '<cmd>Trouble loclist<CR>', { desc = 'Trouble: Location list' })
