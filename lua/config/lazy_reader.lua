local M = {}

local commands = {
  Read = { mode = 'start', desc = 'Read selection' },
  Explain = { mode = 'explain', desc = 'Explain selection' },
  Summarize = { mode = 'summarize', desc = 'Summarize selection' },
  Narrate = { mode = 'narrate', desc = 'Narrate selection' },
  Solve = { mode = 'solve', desc = 'Solve selection' },
  Teach = { mode = 'teach', desc = 'Teach selection' },
}

local function notify(message, level) vim.notify(message, level or vim.log.levels.INFO, { title = 'Lazy Reader' }) end

local function get_selection_region()
  local mode = vim.api.nvim_get_mode().mode
  if mode == 'v' or mode == 'V' or mode == '\22' then return vim.fn.getpos 'v', vim.fn.getpos '.', mode end

  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"
  if start_pos[2] == 0 or end_pos[2] == 0 then return nil end

  return start_pos, end_pos, vim.fn.visualmode()
end

local function get_visual_selection()
  local start_pos, end_pos, mode = get_selection_region()
  if not start_pos or not end_pos then return nil, 'No visual selection available.' end

  local ok, region = pcall(vim.fn.getregion, start_pos, end_pos, { type = mode })
  if not ok then return nil, 'No visual selection available.' end

  local text = table.concat(region, '\n')
  if text:gsub('%s', '') == '' then return nil, 'No visual selection available.' end

  return text
end

function M.run(mode)
  if vim.fn.executable 'lazy-reader' ~= 1 then
    notify('lazy-reader is not available in PATH.', vim.log.levels.ERROR)
    return
  end

  local text, err = get_visual_selection()
  if not text then
    notify(err, vim.log.levels.WARN)
    return
  end

  vim.system({ 'lazy-reader', '--stdin', mode }, { stdin = text, text = true }, function(result)
    if result.code == 0 then return end

    local stderr = vim.trim(result.stderr or '')
    local message = stderr ~= '' and stderr or ('lazy-reader exited with code ' .. result.code)

    vim.schedule(function() notify(message, vim.log.levels.ERROR) end)
  end)
end

function M.setup()
  local map = vim.keymap.set

  for name, spec in pairs(commands) do
    vim.api.nvim_create_user_command('LazyReader' .. name, function() M.run(spec.mode) end, { desc = spec.desc })
  end

  map('x', '<leader>rr', function() M.run 'start' end, { desc = 'Read selection' })
  map('x', '<leader>re', function() M.run 'explain' end, { desc = 'Explain selection' })
  map('x', '<leader>rs', function() M.run 'summarize' end, { desc = 'Summarize selection' })
  map('x', '<leader>rn', function() M.run 'narrate' end, { desc = 'Narrate selection' })
  map('x', '<leader>rp', function() M.run 'solve' end, { desc = 'Solve selection' })
  map('x', '<leader>rt', function() M.run 'teach' end, { desc = 'Teach selection' })
end

return M
