return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
    },
    keys = {
      {
        '<leader>dc',
        function() require('dap').continue() end,
        desc = '[D]ebug [C]ontinue',
      },
      {
        '<leader>db',
        function() require('dap').toggle_breakpoint() end,
        desc = '[D]ebug toggle [B]reakpoint',
      },
      {
        '<leader>dB',
        function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end,
        desc = '[D]ebug conditional [B]reakpoint',
      },
      {
        '<leader>di',
        function() require('dap').step_into() end,
        desc = '[D]ebug step [I]nto',
      },
      {
        '<leader>dl',
        function() require('dap').run_last() end,
        desc = '[D]ebug run [L]ast',
      },
      {
        '<leader>do',
        function() require('dap').step_over() end,
        desc = '[D]ebug step [O]ver',
      },
      {
        '<leader>dO',
        function() require('dap').step_out() end,
        desc = '[D]ebug step [O]ut',
      },
      {
        '<leader>dr',
        function() require('dap').repl.open() end,
        desc = '[D]ebug [R]EPL',
      },
      {
        '<leader>dt',
        function() require('dap').terminate() end,
        desc = '[D]ebug [T]erminate',
      },
      {
        '<leader>du',
        function() require('dapui').toggle() end,
        desc = '[D]ebug toggle [U]I',
      },
      {
        '<leader>dx',
        function() require('config.dap').debug_shell_script() end,
        desc = '[D]ebug shell script',
      },
    },
    config = function() require('config.dap').setup() end,
  },
}
