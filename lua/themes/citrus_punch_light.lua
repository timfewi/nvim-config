local base = require("themes.light_base")

local palette = {
	bg = "#fffef9",
	bg_alt = "#f6f2e7",
	bg_float = "#faf6eb",
	bg_highlight = "#eee5cf",
	bg_visual = "#dce9f7",
	border = "#d9ceb9",
	border_subtle = "#ece3d0",
	comment = "#8d846f",
	cursor = "#f97355",
	fg = "#28313a",
	fg_alt = "#43505c",
	fg_muted = "#7c8792",
	white = "#1f2830",
	teal = "#1f9b90",
	green = "#5d9f5f",
	blue = "#4b7bde",
	blue_bright = "#2c66d8",
	cyan = "#2f7f8c",
	cyan_alt = "#d56c55",
	magenta = "#9654bb",
	magenta_bright = "#7b41a1",
	gold = "#c58a24",
	gold_bright = "#dfa32c",
	sand = "#c58c48",
	string = "#d26b4b",
	string_alt = "#e05f67",
	number = "#9a792d",
	type = "#3d74cb",
	interface = "#2e8b6c",
	struct = "#7360c9",
	function_name = "#e1683e",
	error = "#d93f4a",
	diff_add = "#e8f6e8",
	diff_change = "#e8f0ff",
	diff_delete = "#fde8ea",
	search = "#ffecac",
}

return {
	apply = function()
		base.apply("citrus_punch_light", palette)
	end,
}
