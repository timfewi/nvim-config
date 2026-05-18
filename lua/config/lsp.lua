local M = {}
local util = require 'lspconfig.util'

local function has_lsp_config(name) return #vim.api.nvim_get_runtime_file('lsp/' .. name .. '.lua', false) > 0 end
local function angular_root(fname) return util.root_pattern('angular.json', 'nx.json')(fname) end
local function mason_enabled() return vim.fn.filereadable '/etc/NIXOS' == 0 end

local function powershell_bundle_path()
  local executable = vim.fn.exepath 'powershell-editor-services'
  if executable == '' then return nil end

  local bundle_path = vim.fs.normalize((executable:gsub('/bin/powershell%-editor%-services$', '/lib/powershell-editor-services')))
  if bundle_path == executable or not vim.uv.fs_stat(bundle_path .. '/PowerShellEditorServices/Start-EditorServices.ps1') then
    return nil
  end

  return bundle_path
end

local function typescript_root(fname)
  if angular_root(fname) then return nil end

  return util.root_pattern('tsconfig.json', 'jsconfig.json', 'package.json', '.git')(fname)
end

local function has_any_executable(candidates)
  for _, executable in ipairs(candidates) do
    if vim.fn.executable(executable) == 1 then return true end
  end

  return false
end

local function notify_missing_server(name, candidates)
  local install_hint = mason_enabled()
      and 'Install it with Mason or put it on PATH.'
    or 'Install it via nixos-config; Mason is disabled on NixOS.'

  vim.schedule(function()
    vim.notify_once(
      string.format("Skipping %s: missing executable `%s`. %s", name, table.concat(candidates, '` or `'), install_hint),
      vim.log.levels.ERROR,
      { title = 'nvim-config LSP' }
    )
  end)
end

function M.setup()
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
      local map = function(keys, func, desc, mode)
        mode = mode or 'n'
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
      map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
      map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client:supports_method('textDocument/documentHighlight', event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
          end,
        })
      end

      if client and client:supports_method('textDocument/inlayHint', event.buf) then
        map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
      end
    end,
  })

  local ts_server = has_lsp_config 'ts_ls' and 'ts_ls' or 'tsserver'
  local powershell_bundle = powershell_bundle_path()
  local required_binaries = {
    bashls = { 'bash-language-server' },
    nil_ls = { 'nil' },
    pyright = { 'pyright-langserver', 'pyright' },
    rust_analyzer = { 'rust-analyzer' },
    sqls = { 'sqls' },
    [ts_server] = { 'typescript-language-server' },
    jsonls = { 'vscode-json-language-server' },
  }

  local servers = {
    bashls = {},
    cssls = {},
    docker_compose_language_service = {},
    dockerls = {},
    angularls = {
      root_dir = angular_root,
      single_file_support = false,
    },
    html = {},
    jsonls = {},
    lemminx = {},
    lua_ls = {
      on_init = function(client)
        client.server_capabilities.documentFormattingProvider = false

        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
          runtime = {
            version = 'LuaJIT',
            path = { 'lua/?.lua', 'lua/?/init.lua' },
          },
          workspace = {
            checkThirdParty = false,
            library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
              '${3rd}/luv/library',
              '${3rd}/busted/library',
            }),
          },
        })
      end,
      settings = {
        Lua = {
          format = { enable = false },
        },
      },
    },
    marksman = {},
    nil_ls = {},
    omnisharp = {
      settings = {
        FormattingOptions = {
          EnableEditorConfigSupport = true,
          OrganizeImports = true,
        },
        MsBuild = {
          LoadProjectsOnDemand = false,
        },
        RoslynExtensionsOptions = {
          EnableAnalyzersSupport = true,
          EnableImportCompletion = true,
          AnalyzeOpenDocumentsOnly = false,
          EnableDecompilationSupport = true,
        },
        RenameOptions = {
          RenameInComments = true,
          RenameOverloads = true,
          RenameInStrings = true,
        },
        Sdk = {
          IncludePrereleases = true,
        },
      },
    },
    powershell_es = powershell_bundle and {
      bundle_path = powershell_bundle,
    } or nil,
    pyright = {
      settings = {
        pyright = {
          disableOrganizeImports = false,
        },
        python = {
          analysis = {
            autoSearchPaths = true,
            diagnosticMode = 'workspace',
            typeCheckingMode = 'basic',
            useLibraryCodeForTypes = true,
          },
        },
      },
    },
    rust_analyzer = {
      settings = {
        ['rust-analyzer'] = {
          cargo = {
            allFeatures = true,
          },
          checkOnSave = {
            command = 'clippy',
          },
          procMacro = {
            enable = true,
          },
        },
      },
    },
    sqls = {},
    taplo = {},
    [ts_server] = {
      filetypes = {
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
      },
      init_options = {
        hostInfo = 'neovim',
        preferences = {
          includeCompletionsForImportStatements = true,
          includeCompletionsForModuleExports = true,
          includeCompletionsWithInsertText = true,
          includeCompletionsWithSnippetText = true,
        },
      },
      root_dir = typescript_root,
      settings = {
        javascript = {
          suggest = {
            completeFunctionCalls = true,
          },
          updateImportsOnFileMove = {
            enabled = 'always',
          },
          inlayHints = {
            includeInlayEnumMemberValueHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayParameterNameHints = 'all',
            includeInlayParameterNameHintsWhenArgumentMatchesName = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayVariableTypeHintsWhenTypeMatchesName = true,
          },
        },
        typescript = {
          suggest = {
            completeFunctionCalls = true,
          },
          updateImportsOnFileMove = {
            enabled = 'always',
          },
          inlayHints = {
            includeInlayEnumMemberValueHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayParameterNameHints = 'all',
            includeInlayParameterNameHintsWhenArgumentMatchesName = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayVariableTypeHintsWhenTypeMatchesName = true,
          },
        },
      },
      single_file_support = false,
    },
    yamlls = {},
  }

  for name, server in pairs(servers) do
    if has_lsp_config(name) then
      local candidates = required_binaries[name]
      if candidates and not has_any_executable(candidates) then
        notify_missing_server(name, candidates)
      else
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
      end
    end
  end
end

return M
