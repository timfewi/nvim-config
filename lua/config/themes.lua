local M = {}

M.default = "tokyonight"
M.path = (vim.env.HOME or "") .. "/.local/state/theme/nvim-theme"

M.definitions = {
	mintshot_dark_vs2019 = {
		module = "themes.mintshot_dark_vs2019",
		colorscheme = "mintshot_dark_vs2019",
		background = "dark",
	},
	neon_slate_dark = {
		module = "themes.neon_slate_dark",
		colorscheme = "neon_slate_dark",
		background = "dark",
	},
	ember_ink_dark = {
		module = "themes.ember_ink_dark",
		colorscheme = "ember_ink_dark",
		background = "dark",
	},
	rusty_golem_light = {
		module = "themes.rusty_golem_light",
		colorscheme = "rusty_golem_light",
		background = "light",
	},
	citrus_punch_light = {
		module = "themes.citrus_punch_light",
		colorscheme = "citrus_punch_light",
		background = "light",
	},
	seaglass_pop_light = {
		module = "themes.seaglass_pop_light",
		colorscheme = "seaglass_pop_light",
		background = "light",
	},
	tokyonight = {
		plugin = "folke/tokyonight.nvim",
		module = "tokyonight",
		colorscheme = "tokyonight",
		setup = function(mode)
			return {
				style = mode == "light" and "day" or "night",
				styles = {
					comments = { italic = false },
				},
			}
		end,
	},
	catppuccin = {
		plugin = "catppuccin/nvim",
		name = "catppuccin",
		module = "catppuccin",
		colorscheme = "catppuccin",
		setup = function(mode)
			return {
				flavour = mode == "light" and "latte" or "mocha",
				no_italic = true,
			}
		end,
	},
	gruvbox = {
		plugin = "ellisonleao/gruvbox.nvim",
		module = "gruvbox",
		colorscheme = "gruvbox",
		setup = function(_)
			return {}
		end,
	},
}

function M.names()
	local names = {}
	for name, _ in pairs(M.definitions) do
		table.insert(names, name)
	end

	table.sort(names)
	return names
end

function M.exists(name)
	return M.definitions[name] ~= nil
end

function M.get(name)
	return M.definitions[name] or M.definitions[M.default]
end

function M.current_name()
	local file = io.open(M.path, "r")
	if not file then
		return M.default
	end

	local name = file:read("*a")
	file:close()

	name = name:gsub("%s+", "")
	if M.exists(name) then
		return name
	end

	return M.default
end

function M.plugin_specs()
	local specs = {}

	for _, name in ipairs(M.names()) do
		local theme = M.definitions[name]
		if theme.plugin then
			table.insert(specs, {
				theme.plugin,
				name = theme.name,
				lazy = false,
				priority = 1000,
			})
		end
	end

	return specs
end

function M.next_name(current)
	local names = M.names()

	for index, name in ipairs(names) do
		if name == current then
			return names[index % #names + 1]
		end
	end

	return M.default
end

return M
