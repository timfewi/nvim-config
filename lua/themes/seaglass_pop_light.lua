local base = require("themes.light_base")

local palette = {
	bg = "#fcfffe",
	bg_alt = "#eef6f4",
	bg_float = "#f4fbf8",
	bg_highlight = "#ddecE8",
	bg_visual = "#dde8f7",
	border = "#c8d8d3",
	border_subtle = "#dfebe7",
	comment = "#7a9089",
	cursor = "#1c918b",
	fg = "#24343a",
	fg_alt = "#40565d",
	fg_muted = "#7b8f95",
	white = "#1d2b30",
	teal = "#129b96",
	green = "#509b68",
	blue = "#4a79c6",
	blue_bright = "#2f63b0",
	cyan = "#2d8aa0",
	cyan_alt = "#bf607e",
	magenta = "#9b61cf",
	magenta_bright = "#804eb0",
	gold = "#b58a3f",
	gold_bright = "#ce9b34",
	sand = "#c38c66",
	string = "#cf6080",
	string_alt = "#e0556b",
	number = "#97744b",
	type = "#417aaa",
	interface = "#3f8a73",
	struct = "#7b65a4",
	function_name = "#1f8ea5",
	error = "#ce4f60",
	diff_add = "#e6f6ed",
	diff_change = "#eaf1fc",
	diff_delete = "#fae7ec",
	search = "#f7ecb8",
}

return {
	apply = function()
		base.apply("seaglass_pop_light", palette)
	end,
}
