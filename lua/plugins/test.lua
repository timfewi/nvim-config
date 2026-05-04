return {
  {
    'klen/nvim-test',
    cmd = { 'TestNearest', 'TestFile', 'TestSuite', 'TestLast', 'TestEdit', 'TestVisit', 'TestInfo' },
    keys = {
      { '<leader>ttn', '<cmd>TestNearest<CR>', desc = '[T]est [N]earest' },
      { '<leader>ttf', '<cmd>TestFile<CR>', desc = '[T]est [F]ile' },
      { '<leader>tts', '<cmd>TestSuite<CR>', desc = '[T]est [S]uite' },
      { '<leader>ttl', '<cmd>TestLast<CR>', desc = '[T]est [L]ast' },
      { '<leader>ttv', '<cmd>TestVisit<CR>', desc = '[T]est [V]isit' },
      { '<leader>tte', '<cmd>TestEdit<CR>', desc = '[T]est [E]dit' },
      { '<leader>tti', '<cmd>TestInfo<CR>', desc = '[T]est [I]nfo' },
    },
    config = function()
      require('nvim-test').setup()
    end,
  },
}
