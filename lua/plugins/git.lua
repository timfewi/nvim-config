return {
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
