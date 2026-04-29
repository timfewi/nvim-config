local M = {}

local function executable(name)
  local path = vim.fn.exepath(name)
  if path == '' then return nil end
  return path
end

local function split_args(prompt)
  local input = vim.fn.input(prompt)
  if input == '' then return {} end
  return vim.split(input, ' ', { trimempty = true })
end

local function configure_signs()
  local signs = {
    DapBreakpoint = { text = '●', texthl = 'DiagnosticError' },
    DapBreakpointCondition = { text = '◆', texthl = 'DiagnosticWarn' },
    DapLogPoint = { text = '◆', texthl = 'DiagnosticInfo' },
    DapStopped = { text = '▶', texthl = 'DiagnosticOk', linehl = 'Visual' },
  }

  for name, sign in pairs(signs) do
    vim.fn.sign_define(name, sign)
  end
end

local function configure_python(dap)
  local debugpy_adapter = executable 'debugpy-adapter'
  if not debugpy_adapter then
    vim.notify_once('debugpy-adapter is not available in PATH.', vim.log.levels.WARN)
    return
  end

  local python = executable 'python3' or 'python3'

  dap.adapters.python = {
    type = 'executable',
    command = debugpy_adapter,
  }

  dap.configurations.python = {
    {
      type = 'python',
      request = 'launch',
      name = 'Launch current file',
      program = '${file}',
      cwd = '${workspaceFolder}',
      console = 'integratedTerminal',
      pythonPath = function() return python end,
    },
    {
      type = 'python',
      request = 'launch',
      name = 'Launch module',
      module = function() return vim.fn.input 'Module name: ' end,
      cwd = '${workspaceFolder}',
      console = 'integratedTerminal',
      pythonPath = function() return python end,
      args = function() return split_args 'Module arguments: ' end,
    },
    {
      type = 'python',
      request = 'attach',
      name = 'Attach to process',
      processId = require('dap.utils').pick_process,
      cwd = '${workspaceFolder}',
      pythonPath = function() return python end,
    },
  }
end

local function configure_javascript(dap)
  local js_debug = executable 'js-debug'
  if not js_debug then
    vim.notify_once('js-debug is not available in PATH.', vim.log.levels.WARN)
    return
  end

  for _, adapter in ipairs { 'pwa-node', 'node-terminal' } do
    dap.adapters[adapter] = {
      type = 'server',
      host = '127.0.0.1',
      port = '${port}',
      executable = {
        command = js_debug,
        args = { '${port}' },
      },
    }
  end

  local configurations = {
    {
      type = 'pwa-node',
      request = 'launch',
      name = 'Launch current file',
      program = '${file}',
      cwd = '${workspaceFolder}',
      console = 'integratedTerminal',
      sourceMaps = true,
      skipFiles = {
        '<node_internals>/**',
        '${workspaceFolder}/node_modules/**',
      },
    },
    {
      type = 'pwa-node',
      request = 'launch',
      name = 'Launch current file with args',
      program = '${file}',
      cwd = '${workspaceFolder}',
      console = 'integratedTerminal',
      args = function() return split_args 'Node arguments: ' end,
      sourceMaps = true,
      skipFiles = {
        '<node_internals>/**',
        '${workspaceFolder}/node_modules/**',
      },
    },
    {
      type = 'pwa-node',
      request = 'attach',
      name = 'Attach to process',
      processId = require('dap.utils').pick_process,
      cwd = '${workspaceFolder}',
      skipFiles = {
        '<node_internals>/**',
        '${workspaceFolder}/node_modules/**',
      },
    },
  }

  dap.configurations.javascript = configurations
  dap.configurations.javascriptreact = configurations
  dap.configurations.typescript = configurations
  dap.configurations.typescriptreact = configurations
end

local function configure_dotnet(dap)
  local netcoredbg = executable 'netcoredbg'
  if not netcoredbg then
    vim.notify_once('netcoredbg is not available in PATH.', vim.log.levels.WARN)
    return
  end

  dap.adapters.coreclr = {
    type = 'executable',
    command = netcoredbg,
    args = { '--interpreter=vscode' },
  }

  dap.configurations.cs = {
    {
      type = 'coreclr',
      name = 'Launch .NET project',
      request = 'launch',
      cwd = '${workspaceFolder}',
      stopAtEntry = false,
      program = function()
        local default_path = vim.fn.getcwd() .. '/bin/Debug/'
        local dll_path = vim.fn.input('Path to dll: ', default_path, 'file')

        if dll_path == '' then return nil end

        return vim.fn.fnamemodify(dll_path, ':p')
      end,
    },
    {
      type = 'coreclr',
      name = 'Attach to .NET process',
      request = 'attach',
      processId = require('dap.utils').pick_process,
    },
  }

  pcall(function()
    require('dap.ext.vscode').load_launchjs(nil, {
      coreclr = { 'cs' },
    })
  end)
end

local function configure_c_family(dap)
  local codelldb = vim.env.NVIM_DAP_LLDB_PATH
  local liblldb = vim.env.NVIM_DAP_LLDB_LIB_PATH

  if not codelldb or codelldb == '' then
    vim.notify_once('NVIM_DAP_LLDB_PATH is not set.', vim.log.levels.WARN)
    return
  end

  if not liblldb or liblldb == '' then
    vim.notify_once('NVIM_DAP_LLDB_LIB_PATH is not set.', vim.log.levels.WARN)
    return
  end

  dap.adapters.codelldb = {
    type = 'server',
    port = '${port}',
    executable = {
      command = codelldb,
      args = {
        '--liblldb',
        liblldb,
        '--port',
        '${port}',
      },
    },
  }

  local configurations = {
    {
      type = 'codelldb',
      request = 'launch',
      name = 'Launch executable',
      program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file') end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = function() return split_args 'Program arguments: ' end,
    },
  }

  dap.configurations.c = configurations
  dap.configurations.cpp = configurations
  dap.configurations.rust = configurations
end

local function configure_ui(dap, dapui)
  dapui.setup {
    controls = {
      enabled = true,
      element = 'repl',
    },
    floating = {
      border = 'rounded',
    },
    layouts = {
      {
        elements = {
          { id = 'scopes', size = 0.5 },
          { id = 'breakpoints', size = 0.2 },
          { id = 'stacks', size = 0.15 },
          { id = 'watches', size = 0.15 },
        },
        position = 'left',
        size = 40,
      },
      {
        elements = {
          { id = 'repl', size = 0.5 },
          { id = 'console', size = 0.5 },
        },
        position = 'bottom',
        size = 12,
      },
    },
  }

  require('nvim-dap-virtual-text').setup {
    commented = true,
  }

  dap.listeners.after.event_initialized.dapui_config = function() dapui.open() end
  dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
  dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
end

function M.debug_shell_script()
  local bashdb = executable 'bashdb'
  if not bashdb then
    vim.notify('bashdb is not available in PATH.', vim.log.levels.ERROR)
    return
  end

  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then
    vim.notify('Save the shell script before starting bashdb.', vim.log.levels.ERROR)
    return
  end

  local command = { bashdb, file }
  local args = split_args 'Shell script arguments: '

  for _, arg in ipairs(args) do
    table.insert(command, arg)
  end

  vim.cmd 'botright split'
  vim.cmd 'resize 14'
  vim.fn.termopen(command)
end

function M.setup()
  local dap = require 'dap'
  local dapui = require 'dapui'

  configure_signs()
  configure_ui(dap, dapui)
  configure_python(dap)
  configure_javascript(dap)
  configure_dotnet(dap)
  configure_c_family(dap)

  vim.api.nvim_create_user_command('DebugBash', function() M.debug_shell_script() end, {
    desc = 'Debug current shell script with bashdb',
    force = true,
  })
end

return M
