local base = require("themes.light_base")

local palette = {
	bg = "#fffdfa",
	bg_alt = "#f5efe8",
	bg_float = "#f8f2eb",
	bg_highlight = "#ece3d9",
	bg_visual = "#dbe5ec",
	border = "#d2c5b8",
	border_subtle = "#e9dfd4",
	comment = "#8c7e73",
	cursor = "#8e5d4a",
	fg = "#2f353c",
	fg_alt = "#46525c",
	fg_muted = "#7d8790",
	white = "#23292f",
	teal = "#5a827b",
	green = "#5f8a66",
	blue = "#5f7f94",
	blue_bright = "#466d8d",
	cyan = "#6d7f89",
	cyan_alt = "#8a6c60",
	magenta = "#8a6878",
	magenta_bright = "#76586d",
	gold = "#9a7a4c",
	gold_bright = "#b2894d",
	sand = "#a9875f",
	string = "#9d614e",
	string_alt = "#b45e57",
	number = "#8b724c",
	type = "#5b6e7b",
	interface = "#6a786b",
	struct = "#75677f",
	function_name = "#7b5042",
	error = "#c4544b",
	diff_add = "#e6f0e6",
	diff_change = "#e8eff4",
	diff_delete = "#f7e6e5",
	search = "#f4e4c6",
}

return {
	apply = function()
		base.apply("rusty_golem_light", palette)
	end,
}
