return {
  {
    'sindrets/diffview.nvim',
    cmd = {
      'DiffviewOpen',
      'DiffviewClose',
      'DiffviewToggleFiles',
      'DiffviewFocusFiles',
      'DiffviewFileHistory',
      'DiffviewRefresh',
      'DiffviewLog',
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<CR>', desc = '[G]it [D]iff view' },
      { '<leader>gD', '<cmd>DiffviewClose<CR>', desc = '[G]it diff close' },
      { '<leader>gm', '<cmd>DiffviewOpen<CR>', desc = '[G]it [M]erge/conflict view' },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<CR>', desc = '[G]it file [H]istory' },
      { '<leader>gH', '<cmd>DiffviewFileHistory<CR>', desc = '[G]it repo history' },
      { '<leader>ge', '<cmd>DiffviewFocusFiles<CR>', desc = '[G]it diff focus fil[e]s' },
      { '<leader>gb', '<cmd>DiffviewToggleFiles<CR>', desc = '[G]it diff side[b]ar' },
      {
        '<leader>gu',
        function()
          require('gitsigns').preview_hunk_inline()
        end,
        desc = '[G]it inline diff in c[U]rrent buffer',
      },
    },
    opts = {
      enhanced_diff_hl = true,
      use_icons = true,
      view = {
        default = {
          layout = 'diff2_horizontal',
        },
        merge_tool = {
          layout = 'diff3_mixed',
          disable_diagnostics = true,
        },
        file_history = {
          layout = 'diff2_horizontal',
        },
      },
      file_panel = {
        win_config = {
          position = 'left',
          width = 35,
        },
      },
      file_history_panel = {
        win_config = {
          position = 'bottom',
          height = 16,
        },
      },
    },
  },
  {
    'kdheepak/lazygit.nvim',
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    keys = {
      { '<leader>gg', '<cmd>LazyGit<CR>', desc = '[G]it [G]ui (lazygit)' },
      { '<leader>gf', '<cmd>LazyGitCurrentFile<CR>', desc = '[G]it current [F]ile' },
    },
    init = function()
      vim.g.lazygit_floating_window_use_plenary = 1
      vim.g.lazygit_floating_window_scaling_factor = 0.9
    end,
  },
}
