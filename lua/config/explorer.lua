local M = {}

local function current_dir()
	local path = vim.fn.expand("%:p:h")
	if path == "" then
		return vim.fn.getcwd()
	end
	return path
end

local function startup_dir()
	if vim.fn.argc(-1) ~= 1 then
		return nil
	end

	local path = vim.fn.argv(0)
	if path == "" or vim.fn.isdirectory(path) == 0 then
		return nil
	end

	return vim.fn.fnamemodify(path, ":p")
end

function M.opts()
	return {
		close_if_last_window = true,
		enable_diagnostics = true,
		enable_git_status = true,
		popup_border_style = "rounded",
		default_component_configs = {
			container = {
				enable_character_fade = false,
			},
			git_status = {
				symbols = {
					added = "",
					deleted = "",
					modified = "",
					renamed = "➜",
					untracked = "★",
					ignored = "◌",
					unstaged = "✗",
					staged = "✓",
					conflict = "",
				},
			},
			indent = {
				indent_size = 2,
				padding = 1,
				with_expanders = true,
				expander_collapsed = "",
				expander_expanded = "",
			},
			modified = {
				symbol = "[+]",
			},
		},
		filesystem = {
			bind_to_cwd = false,
			filtered_items = {
				hide_dotfiles = false,
				hide_gitignored = false,
			},
			follow_current_file = {
				enabled = true,
				leave_dirs_open = true,
			},
			group_empty_dirs = true,
			hijack_netrw_behavior = "open_current",
			use_libuv_file_watcher = true,
			window = {
				mappings = {
					["<space>"] = "toggle_node",
				},
			},
		},
		window = {
			position = "left",
			width = 36,
			mappings = {
				["<cr>"] = "open",
				["l"] = "open",
				["h"] = "close_node",
				["P"] = { "toggle_preview", config = { use_float = true } },
			},
		},
	}
end

function M.toggle()
	require("neo-tree.command").execute({
		toggle = true,
		dir = current_dir(),
		position = "left",
		reveal = true,
		source = "filesystem",
	})
end

function M.reveal()
	require("neo-tree.command").execute({
		toggle = true,
		position = "left",
		reveal = true,
		source = "filesystem",
	})
end

function M.open_startup_dir()
	local dir = startup_dir()
	if dir == nil then
		return
	end

	vim.schedule(function()
		vim.cmd("cd " .. vim.fn.fnameescape(dir))
		require("neo-tree.command").execute({
			action = "show",
			dir = dir,
			position = "left",
			source = "filesystem",
		})
	end)
end

function M.setup()
	require("neo-tree").setup(M.opts())

	vim.keymap.set("n", "-", M.toggle, { desc = "Toggle file explorer" })
	vim.keymap.set("n", "<leader>e", M.reveal, { desc = "Reveal current file in [E]xplorer" })

	M.open_startup_dir()
end

return M
