local function openrouter_api_key_name()
  if vim.env.OPENROUTER_API_KEY_FILE ~= nil and vim.env.OPENROUTER_API_KEY_FILE ~= '' then
    return 'cmd:test -n "$OPENROUTER_API_KEY_FILE" && tr -d "\\r\\n" < "$OPENROUTER_API_KEY_FILE"'
  end

  if vim.env.OPENROUTER_API_KEY ~= nil and vim.env.OPENROUTER_API_KEY ~= '' then
    return 'OPENROUTER_API_KEY'
  end

  -- No key configured (neither OPENROUTER_API_KEY_FILE from Nix nor
  -- OPENROUTER_API_KEY as fallback). Return empty so Avante skips the
  -- key-prompt dialog silently; run `nixos-rebuild switch` to set the
  -- agenix-backed OPENROUTER_API_KEY_FILE env var, or set OPENROUTER_API_KEY
  -- directly.
  return ''
end

return {
  {
    'yetone/avante.nvim',
    event = 'VeryLazy',
    version = false,
    build = 'make',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
      {
        'MeanderingProgrammer/render-markdown.nvim',
        ft = { 'markdown', 'Avante' },
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
      },
    },
    config = function(_, _)
      -- Monkey-patch Avante's native input provider: upstream bug uses
      -- vim.ui.select() instead of vim.ui.input(), causing telescope-ui-select
      -- to crash (receives a function as opts). When dressing.nvim is installed
      -- this also ensures concealed/password input works properly.
      local ok, native = pcall(require, 'avante.ui.input.providers.native')
      if ok and native then
        native.show = function(self)
          local input = self
          -- upstream line 20: vim.ui.select(opts, input.on_submit)
          --   should be:     vim.ui.input(opts, input.on_submit)
          vim.ui.input({
            prompt = input.prompt,
            default = input.default,
            completion = input.completion,
          }, input.on_submit)
        end
      end

      require('avante').setup {
        provider = 'openrouter',
        selector = {
          provider = 'telescope',
          provider_opts = {},
        },
        behaviour = {
          auto_suggestions = false,
          enable_token_counting = false,
          auto_approve_tool_permissions = false,
        },
        providers = {
          openrouter = {
            __inherited_from = 'openai',
            endpoint = 'https://openrouter.ai/api/v1',
            model = 'qwen/qwen3.6-flash',
            api_key_name = openrouter_api_key_name(),
            timeout = 30000,
            extra_request_body = {
              temperature = 0,
              max_tokens = 4096,
            },
          },
        }
      }

      vim.keymap.set('n', '<leader>aC', function()
        require('avante').toggle.selection()
      end, { desc = 'Avante: toggle selection' })
    end,
  },
}
