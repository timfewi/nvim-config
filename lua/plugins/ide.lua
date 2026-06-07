return {
  {
    'ray-x/lsp_signature.nvim',
    event = 'LspAttach',
    config = function()
      require('lsp_signature').setup {
        bind = true,
        handler_opts = { border = 'rounded' },
        hint_inline = function() return false end,
      }
    end,
  },
  {
    'kosayoda/nvim-lightbulb',
    event = 'LspAttach',
    config = function()
      require('nvim-lightbulb').setup {
        autocmd = { enabled = true },
        sign = { enabled = true },
      }
    end,
  },
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    opts = {},
  },
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'rachartier/tiny-code-action.nvim',
    event = 'LspAttach',
    config = function()
      require('tiny-code-action').setup()
    end,
  },
}