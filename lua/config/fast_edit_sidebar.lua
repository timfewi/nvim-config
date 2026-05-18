local M = {}

local HIGHLIGHT_NS = vim.api.nvim_create_namespace 'fast-edit-sidebar'
local KEY_COLUMN_WIDTH = 20
local MIN_WIDTH = 36
local WIDTH_RATIO = 0.22
local AUGROUP = vim.api.nvim_create_augroup('fast-edit-sidebar', { clear = true })

local state = {
  bufnr = nil,
  source_bufnr = nil,
  winid = nil,
}

local core_sections = {
  {
    title = 'Core motions',
    items = {
      { lhs = 'h / j / k / l', desc = 'Move left, down, up, right' },
      { lhs = 'w / b / e', desc = 'Jump by word' },
      { lhs = '0 / ^ / $', desc = 'Jump to line start or end' },
      { lhs = 'gg / G', desc = 'Jump to top or bottom of file' },
      { lhs = '%', desc = 'Jump between matching pairs' },
      { lhs = 'f<char> / t<char>', desc = 'Jump to a character on the line' },
      { lhs = '* / #', desc = 'Search current word forward or back' },
      { lhs = 'n / N', desc = 'Repeat the last search' },
      { lhs = '{ / }', desc = 'Jump by paragraph' },
      { lhs = 'zz', desc = 'Center the current line' },
    },
  },
  {
    title = 'Editing essentials',
    items = {
      { lhs = 'i / a', desc = 'Insert before or after the cursor' },
      { lhs = 'o / O', desc = 'Open a line below or above' },
      { lhs = 'v / V', desc = 'Start visual or linewise visual mode' },
      { lhs = 'x / X', desc = 'Delete character under or before cursor' },
      { lhs = 'dw / cw', desc = 'Delete or change a word' },
      { lhs = 'dd / yy', desc = 'Delete or yank a line' },
      { lhs = 'p / P', desc = 'Paste after or before the cursor' },
      { lhs = 'u / <C-r>', desc = 'Undo or redo' },
      { lhs = '.', desc = 'Repeat the last change' },
      { lhs = 'ciw', desc = 'Change the word under the cursor' },
      { lhs = '>> / <<', desc = 'Indent or outdent a line' },
      { lhs = 'J', desc = 'Join the next line onto this one' },
    },
  },
}

local generated_sections = {
  {
    title = 'Windows & buffers',
    items = {
      { mode = 'n', lhs = '-', desc = 'Open parent directory' },
      { mode = 'n', lhs = '<leader>bb', desc = 'Switch to previous buffer' },
      { mode = 'n', lhs = '<leader>e', desc = 'Open line diagnostics' },
      { mode = 'n', lhs = '<leader>q', desc = 'Open diagnostic location list' },
      { mode = 'n', lhs = '[d', desc = 'Previous diagnostic' },
      { mode = 'n', lhs = ']d', desc = 'Next diagnostic' },
      { mode = 'n', lhs = '<C-h>', desc = 'Move focus to the left window' },
      { mode = 'n', lhs = '<C-j>', desc = 'Move focus to the lower window' },
      { mode = 'n', lhs = '<C-k>', desc = 'Move focus to the upper window' },
      { mode = 'n', lhs = '<C-l>', desc = 'Move focus to the right window' },
    },
  },
  {
    title = 'Search & files',
    items = {
      { mode = 'n', lhs = '<leader><leader>', desc = 'Find existing buffers' },
      { mode = 'n', lhs = '<leader>sf', desc = 'Search files' },
      { mode = 'n', lhs = '<leader>sg', desc = 'Search by grep' },
      { mode = 'n', lhs = '<leader>sw', desc = 'Search current word' },
      { mode = 'n', lhs = '<leader>sd', desc = 'Search diagnostics' },
      { mode = 'n', lhs = '<leader>ss', desc = 'Search Telescope pickers' },
      { mode = 'n', lhs = '<leader>sc', desc = 'Search commands' },
      { mode = 'n', lhs = '<leader>sh', desc = 'Search help tags' },
      { mode = 'n', lhs = '<leader>sk', desc = 'Search keymaps' },
      { mode = 'n', lhs = '<leader>sn', desc = 'Search Neovim files' },
      { mode = 'n', lhs = '<leader>s/', desc = 'Live grep in open files' },
      { mode = 'n', lhs = '<leader>/', desc = 'Fuzzy search current buffer' },
      { mode = 'n', lhs = '<leader>sr', desc = 'Resume last search' },
      { mode = 'n', lhs = '<leader>s.', desc = 'Open recent files' },
    },
  },
  {
    title = 'LSP & code (buffer local)',
    items = {
      { mode = 'n', lhs = 'grn', desc = 'Rename symbol' },
      { mode = 'n', lhs = 'gra', desc = 'Code action' },
      { mode = 'n', lhs = 'grD', desc = 'Go to declaration' },
      { mode = 'n', lhs = 'grd', desc = 'Go to definition' },
      { mode = 'n', lhs = 'grr', desc = 'Go to references' },
      { mode = 'n', lhs = 'gri', desc = 'Go to implementation' },
      { mode = 'n', lhs = 'grt', desc = 'Go to type definition' },
      { mode = 'n', lhs = 'gO', desc = 'Document symbols' },
      { mode = 'n', lhs = 'gW', desc = 'Workspace symbols' },
      { mode = 'n', lhs = '<leader>f', desc = 'Format buffer' },
      { mode = 'n', lhs = '<leader>th', desc = 'Toggle inlay hints' },
    },
  },
  {
    title = 'Git',
    items = {
      { mode = 'n', lhs = ']h', desc = 'Next git hunk' },
      { mode = 'n', lhs = '[h', desc = 'Previous git hunk' },
      { mode = 'n', lhs = '<leader>hp', desc = 'Preview git hunk' },
      { mode = 'n', lhs = '<leader>hi', desc = 'Inline hunk preview' },
      { mode = 'n', lhs = '<leader>hd', desc = 'Diff current file' },
      { mode = 'n', lhs = '<leader>gt', desc = 'Toggle git signs' },
      { mode = 'n', lhs = '<leader>tw', desc = 'Toggle git word diff' },
      { mode = 'n', lhs = '<leader>gd', desc = 'Open diff view' },
      { mode = 'n', lhs = '<leader>gD', desc = 'Close diff view' },
      { mode = 'n', lhs = '<leader>gm', desc = 'Open merge or conflict view' },
      { mode = 'n', lhs = '<leader>gh', desc = 'File history' },
      { mode = 'n', lhs = '<leader>gH', desc = 'Repository history' },
      { mode = 'n', lhs = '<leader>ge', desc = 'Focus diff files' },
      { mode = 'n', lhs = '<leader>gb', desc = 'Toggle diff sidebar' },
      { mode = 'n', lhs = '<leader>gg', desc = 'Open lazygit' },
      { mode = 'n', lhs = '<leader>gf', desc = 'Open lazygit for current file' },
      { mode = 'n', lhs = '<leader>gu', desc = 'Inline diff in current buffer' },
    },
  },
  {
    title = 'Visual selection tools',
    items = {
      { mode = 'x', lhs = '<leader>rr', desc = 'Read selection' },
      { mode = 'x', lhs = '<leader>re', desc = 'Explain selection' },
      { mode = 'x', lhs = '<leader>rs', desc = 'Summarize selection' },
      { mode = 'x', lhs = '<leader>rn', desc = 'Narrate selection' },
      { mode = 'x', lhs = '<leader>rp', desc = 'Solve selection' },
      { mode = 'x', lhs = '<leader>rt', desc = 'Teach selection' },
    },
  },
  {
    title = 'Terminal & debug',
    items = {
      { mode = 't', lhs = '<Esc><Esc>', desc = 'Exit terminal mode' },
      { mode = 'n', lhs = '<leader>dc', desc = 'Debug continue' },
      { mode = 'n', lhs = '<leader>db', desc = 'Toggle breakpoint' },
      { mode = 'n', lhs = '<leader>dB', desc = 'Conditional breakpoint' },
      { mode = 'n', lhs = '<leader>di', desc = 'Step into' },
      { mode = 'n', lhs = '<leader>do', desc = 'Step over' },
      { mode = 'n', lhs = '<leader>dO', desc = 'Step out' },
      { mode = 'n', lhs = '<leader>dl', desc = 'Run last debug session' },
      { mode = 'n', lhs = '<leader>dr', desc = 'Open debug REPL' },
      { mode = 'n', lhs = '<leader>dt', desc = 'Terminate debug session' },
      { mode = 'n', lhs = '<leader>du', desc = 'Toggle debug UI' },
      { mode = 'n', lhs = '<leader>dx', desc = 'Debug current shell script' },
    },
  },
}

local function trim(text)
  return (text:gsub('^%s+', ''):gsub('%s+$', ''))
end

local function clean_desc(desc)
  desc = desc:gsub('%[', '')
  desc = desc:gsub('%]', '')
  desc = desc:gsub('%s+', ' ')
  return trim(desc)
end

local function sidebar_width()
  return math.max(MIN_WIDTH, math.floor(vim.o.columns * WIDTH_RATIO))
end

local function is_valid_buf(bufnr)
  return bufnr ~= nil and vim.api.nvim_buf_is_valid(bufnr)
end

local function is_valid_win(winid)
  return winid ~= nil and vim.api.nvim_win_is_valid(winid)
end

local function clear_state()
  state.bufnr = nil
  state.source_bufnr = nil
  state.winid = nil
end

local function current_source_buf()
  local bufnr = vim.api.nvim_get_current_buf()
  if bufnr ~= state.bufnr then return bufnr end
  if is_valid_buf(state.source_bufnr) then return state.source_bufnr end
  return nil
end

local function build_mapping_index(bufnr)
  local index = {}

  local function record_maps(mode, maps)
    for _, map in ipairs(maps) do
      if map.lhs and map.desc then
        local key = mode .. '\n' .. map.lhs
        if index[key] == nil then index[key] = clean_desc(map.desc) end
      end
    end
  end

  for _, mode in ipairs { 'n', 'x', 't' } do
    record_maps(mode, vim.api.nvim_get_keymap(mode))
    if bufnr and is_valid_buf(bufnr) then
      record_maps(mode, vim.api.nvim_buf_get_keymap(bufnr, mode))
    end
  end

  return index
end

local function section_items(section, mapping_index)
  local items = {}

  for _, item in ipairs(section.items) do
    if item.mode == nil then
      items[#items + 1] = {
        lhs = item.lhs,
        desc = item.desc,
      }
    else
      local key = item.mode .. '\n' .. item.lhs
      local desc = mapping_index[key] or item.desc
      if desc then
        items[#items + 1] = {
          lhs = item.lhs,
          desc = clean_desc(desc),
        }
      end
    end
  end

  return items
end

local function set_sidebar_options(winid, bufnr)
  vim.bo[bufnr].buftype = 'nofile'
  vim.bo[bufnr].bufhidden = 'wipe'
  vim.bo[bufnr].buflisted = false
  vim.bo[bufnr].filetype = 'fast-edit-sidebar'
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].readonly = true
  vim.bo[bufnr].swapfile = false

  vim.wo[winid].breakindent = true
  vim.wo[winid].cursorline = false
  vim.wo[winid].foldcolumn = '0'
  vim.wo[winid].linebreak = true
  vim.wo[winid].list = false
  vim.wo[winid].number = false
  vim.wo[winid].relativenumber = false
  vim.wo[winid].signcolumn = 'no'
  vim.wo[winid].spell = false
  vim.wo[winid].statuscolumn = ''
  vim.wo[winid].winfixwidth = true
  vim.wo[winid].wrap = true
end

local function set_sidebar_keymaps(bufnr)
  vim.keymap.set('n', 'q', M.close, { buffer = bufnr, desc = 'Close fast edit sidebar' })
  vim.keymap.set('n', '<Esc>', M.close, { buffer = bufnr, desc = 'Close fast edit sidebar' })
  vim.keymap.set('n', 'R', M.refresh, { buffer = bufnr, desc = 'Refresh fast edit sidebar' })
end

local function apply_highlights(bufnr, specs)
  vim.api.nvim_buf_clear_namespace(bufnr, HIGHLIGHT_NS, 0, -1)

  for _, spec in ipairs(specs) do
    vim.api.nvim_buf_add_highlight(bufnr, HIGHLIGHT_NS, spec.group, spec.line, spec.start_col, spec.end_col)
  end
end

local function render(bufnr, source_bufnr)
  local mapping_index = build_mapping_index(source_bufnr)
  local lines = {}
  local highlights = {}

  local function append_line(text)
    lines[#lines + 1] = text
    return #lines - 1
  end

  local function highlight_line(group, line, start_col, end_col)
    highlights[#highlights + 1] = {
      group = group,
      line = line,
      start_col = start_col or 0,
      end_col = end_col or -1,
    }
  end

  local title_line = append_line 'FAST EDIT SHORTCUTS'
  highlight_line('FastEditSidebarTitle', title_line)

  append_line ''

  local leader_line = append_line 'Leader: <Space>'
  local close_line = append_line 'q closes this sidebar'
  local refresh_line = append_line 'R refreshes the list'
  highlight_line('FastEditSidebarHint', leader_line)
  highlight_line('FastEditSidebarHint', close_line)
  highlight_line('FastEditSidebarHint', refresh_line)

  append_line ''

  local sections = {}
  for _, section in ipairs(core_sections) do
    sections[#sections + 1] = {
      title = section.title,
      items = section_items(section, mapping_index),
    }
  end
  for _, section in ipairs(generated_sections) do
    sections[#sections + 1] = {
      title = section.title,
      items = section_items(section, mapping_index),
    }
  end

  for _, section in ipairs(sections) do
    local section_line = append_line(section.title)
    highlight_line('FastEditSidebarSection', section_line)

    for _, item in ipairs(section.items) do
      local line = append_line(string.format('  %-' .. KEY_COLUMN_WIDTH .. 's %s', item.lhs, item.desc))
      highlight_line('FastEditSidebarKey', line, 2, 2 + #item.lhs)
    end
    append_line ''
  end

  vim.bo[bufnr].modifiable = true
  vim.bo[bufnr].readonly = false
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].readonly = true
  apply_highlights(bufnr, highlights)
end

local function ensure_sidebar()
  if is_valid_win(state.winid) and is_valid_buf(state.bufnr) then return state.winid, state.bufnr end

  local original_win = vim.api.nvim_get_current_win()
  vim.cmd 'vsplit'

  state.winid = vim.api.nvim_get_current_win()
  state.bufnr = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_win_set_buf(state.winid, state.bufnr)
  vim.api.nvim_win_set_width(state.winid, sidebar_width())
  set_sidebar_options(state.winid, state.bufnr)
  set_sidebar_keymaps(state.bufnr)

  vim.api.nvim_create_autocmd('BufWipeout', {
    group = AUGROUP,
    buffer = state.bufnr,
    once = true,
    callback = clear_state,
    desc = 'Reset fast edit sidebar state when its buffer is wiped',
  })

  if is_valid_win(original_win) then vim.api.nvim_set_current_win(original_win) end

  return state.winid, state.bufnr
end

function M.refresh()
  if not is_valid_buf(state.bufnr) then return end

  local source_bufnr = current_source_buf()
  if source_bufnr ~= nil then state.source_bufnr = source_bufnr end

  render(state.bufnr, state.source_bufnr)
  if is_valid_win(state.winid) then vim.api.nvim_win_set_width(state.winid, sidebar_width()) end
end

function M.open()
  local source_bufnr = current_source_buf()
  if source_bufnr ~= nil then state.source_bufnr = source_bufnr end

  ensure_sidebar()
  M.refresh()
end

function M.close()
  if is_valid_win(state.winid) then
    vim.api.nvim_win_close(state.winid, true)
  elseif is_valid_buf(state.bufnr) then
    vim.api.nvim_buf_delete(state.bufnr, { force = true })
  end

  clear_state()
end

function M.toggle()
  if is_valid_win(state.winid) then
    M.close()
    return
  end

  M.open()
end

function M.setup()
  vim.api.nvim_set_hl(0, 'FastEditSidebarTitle', { link = 'Title' })
  vim.api.nvim_set_hl(0, 'FastEditSidebarSection', { link = 'Special' })
  vim.api.nvim_set_hl(0, 'FastEditSidebarKey', { link = 'Identifier' })
  vim.api.nvim_set_hl(0, 'FastEditSidebarHint', { link = 'Comment' })

  vim.keymap.set('n', '<leader>?', M.toggle, { desc = 'Toggle fast edit shortcuts' })

  vim.api.nvim_create_user_command('FastEditHelp', function() M.open() end, {
    desc = 'Open the fast edit shortcuts sidebar',
  })

  vim.api.nvim_create_user_command('FastEditHelpToggle', function() M.toggle() end, {
    desc = 'Toggle the fast edit shortcuts sidebar',
  })

  vim.api.nvim_create_autocmd('VimResized', {
    group = AUGROUP,
    callback = function()
      if is_valid_win(state.winid) then vim.api.nvim_win_set_width(state.winid, sidebar_width()) end
    end,
    desc = 'Keep the fast edit sidebar sized to the current editor width',
  })
end

return M
