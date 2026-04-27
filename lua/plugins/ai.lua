local function read_secret_file(path)
  local secret_file = io.open(path, 'r')
  if secret_file == nil then return nil, ('Avante: unable to open OPENROUTER_API_KEY_FILE at %s'):format(path) end

  local secret = secret_file:read '*a'
  secret_file:close()

  if secret == nil then return nil, 'Avante: failed to read OPENROUTER_API_KEY_FILE' end

  secret = secret:gsub('%s+$', '')
  if secret == '' then return nil, 'Avante: OPENROUTER_API_KEY_FILE is empty' end

  return secret
end

local function ensure_openrouter_api_key()
  if vim.env.OPENROUTER_API_KEY ~= nil and vim.env.OPENROUTER_API_KEY ~= '' then return true end

  local key_file = vim.env.OPENROUTER_API_KEY_FILE
  if not key_file or key_file == '' then
    vim.notify_once('Avante: OPENROUTER_API_KEY_FILE is not set', vim.log.levels.WARN)
    return false
  end

  local api_key, err = read_secret_file(key_file)
  if not api_key then
    vim.notify_once(err or ('Avante: failed to read ' .. key_file),vim.log.levels.WARN)
    return false
  end

  vim.env.OPENROUTER_API_KEY = api_key
  return true
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
    opts = function()
      ensure_openrouter_api_key()

      return {
        provider = 'openrouter',
        auto_suggestions_provider = 'openrouter',
        selector = {
          provider = 'telescope',
          provider_opts = {},
        },
        behaviour = {
          auto_suggestions = true,
          auto_approve_tool_permissions = false,
        },
        providers = {
          openrouter = {
            __inherited_from = 'openai',
            endpoint = 'https://openrouter.ai/api/v1',
            model = 'qwen/qwen3.6-flash',
            api_key_name = 'OPENROUTER_API_KEY',
            timeout = 30000,
            extra_request_body = {
              temperature = 0,
              max_tokens = 4096,
            },
          },
        },
      }
    end,
  },
}
