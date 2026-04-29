return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		event = "VimEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		init = function()
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1
		end,
		config = function()
			require("config.explorer").setup()
		end,
	},
}
