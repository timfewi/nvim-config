return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function() require('config.lsp').setup() end,
  },
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function() require('conform').format { async = true } end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local enabled_filetypes = {}
        if enabled_filetypes[vim.bo[bufnr].filetype] then return { timeout_ms = 500 } end
      end,
      default_format_opts = {
        lsp_format = 'fallback',
      },
      formatters_by_ft = {
        bash = { 'shfmt' },
        css = { 'prettier' },
        html = { 'prettier' },
        javascript = { 'biome' },
        javascriptreact = { 'biome' },
        json = { 'biome' },
        jsonc = { 'biome' },
        less = { 'prettier' },
        lua = { 'stylua' },
        markdown = { 'prettier' },
        nix = { 'nixfmt' },
        python = { 'ruff_format' },
        rust = { 'rustfmt' },
        scss = { 'prettier' },
        sh = { 'shfmt' },
        zsh = { 'shfmt' },
        toml = { 'taplo' },
        typescript = { 'biome' },
        typescriptreact = { 'biome' },
        yaml = { 'prettier' },
      },
    },
  },
  {
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          if vim.fn.executable 'make' == 0 then return end
          return 'make install_jsregexp'
        end)(),
        opts = {},
      },
    },
    opts = {
      keymap = {
        preset = 'default',
      },
      appearance = {
        nerd_font_variant = 'mono',
      },
      completion = {
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets' },
      },
      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'lua' },
      signature = { enabled = true },
    },
  },
}
