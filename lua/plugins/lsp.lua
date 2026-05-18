local function mason_enabled()
  return vim.fn.filereadable '/etc/NIXOS' == 0
end

return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'j-hui/fidget.nvim', opts = {} },
      { 'williamboman/mason.nvim', cond = mason_enabled },
    },
    config = function() require('config.lsp').setup() end,
  },
  {
    'williamboman/mason.nvim',
    cond = mason_enabled,
    opts = {
      ensure_installed = {
        'rust-analyzer',
        'lua-language-server',
        'typescript-language-server',
        'json-lsp',
        'nil',
        'pyright',
        'bash-language-server',
        'sqls',
        'yaml-language-server',
        'dockerfile-language-server',
        'marksman',
        'taplo',
        'stylua',
        'prettier',
        'shfmt',
        'ruff',
      },
    },
  },
  {
    'williamboman/mason-lspconfig.nvim',
    cond = mason_enabled,
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
    },
    opts = {},
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
        javascript = { 'prettier' },
        javascriptreact = { 'prettier' },
        json = { 'prettier' },
        jsonc = { 'prettier' },
        less = { 'prettier' },
        lua = { 'stylua' },
        markdown = { 'prettier' },
        nix = { 'nixfmt' },
        python = { 'ruff_format' },
        rust = { 'rustfmt' },
        scss = { 'prettier' },
        sh = { 'shfmt' },
        toml = { 'taplo' },
        typescript = { 'prettier' },
        typescriptreact = { 'prettier' },
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
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end
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
