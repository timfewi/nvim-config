return {
  { 'NMAC427/guess-indent.nvim', opts = {} },
  {
    'lewis6991/gitsigns.nvim',
    opts = function()
      return {
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
        word_diff = true,
        on_attach = function(bufnr)
          local gitsigns = require 'gitsigns'

          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end

          map('n', ']h', function()
            if vim.wo.diff then
              vim.cmd.normal { ']c', bang = true }
              return
            end

            gitsigns.nav_hunk 'next'
          end, 'Next git hunk')

          map('n', '[h', function()
            if vim.wo.diff then
              vim.cmd.normal { '[c', bang = true }
              return
            end

            gitsigns.nav_hunk 'prev'
          end, 'Previous git hunk')

          map('n', '<leader>hp', gitsigns.preview_hunk, 'Git [H]unk [P]review')
          map('n', '<leader>hi', gitsigns.preview_hunk_inline, 'Git hunk [I]nline preview')
          map('n', '<leader>hd', function()
            gitsigns.diffthis(nil, { vertical = true })
          end, 'Git [H]unk [D]iff current file')
        end,
      }
    end,
    keys = {
      {
        '<leader>gt',
        function()
          local gitsigns = require 'gitsigns'

          if vim.b.gitsigns_head ~= nil then
            gitsigns.detach()
            return
          end

          gitsigns.attach()
        end,
        desc = '[G]it [T]oggle changes',
      },
      {
        '<leader>tw',
        function()
          require('gitsigns').toggle_word_diff()
        end,
        desc = '[T]oggle git [W]ord diff',
      },
    },
  },
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },
      spec = {
        { '<leader>a', group = '[A]vante' },
        { '<leader>b', group = '[B]uffers' },
        { '<leader>d', group = '[D]ebug' },
        { '<leader>g', group = '[G]it' },
        { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
        { '<leader>t',  group = '[T]oggle' },
        { '<leader>tt', group = '[T]est' },
        { 'gr', group = 'LSP Actions', mode = { 'n' } },
      },
    },
  },
}
