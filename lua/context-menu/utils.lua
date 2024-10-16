local _M = {}

local function get_width(lines)
	local len = 0;
	for _, line in ipairs(lines) do
		if # line > len then
			len = # line
		end
	end;
	return len + 1
end;
local function set_highlight(group, style)
	if type(style) == "string" then
		vim.api.nvim_set_hl(0, group, {
			link = style
		})
	else
		vim.api.nvim_set_hl(0, group, style)
	end
end;
local function get_hl_group(group_name)
	local group_id = vim.fn.synIDtrans(vim.fn.hlID(group_name));
	return {
		fg = vim.fn.synIDattr(group_id, "fg#"),
		bg = vim.fn.synIDattr(group_id, "bg#"),
		sp = vim.fn.synIDattr(group_id, "sp#"),
		bold = vim.fn.synIDattr(group_id, "bold") == "1",
		standout = vim.fn.synIDattr(group_id, "standout") == "1",
		underline = vim.fn.synIDattr(group_id, "underline") == "1",
		undercurl = vim.fn.synIDattr(group_id, "undercurl") == "1",
		underdouble = vim.fn.synIDattr(group_id, "underdouble") == "1",
		underdotted = vim.fn.synIDattr(group_id, "underdotted") == "1",
		underdashed = vim.fn.synIDattr(group_id, "underdashed") == "1",
		strikethrough = vim.fn.synIDattr(group_id, "strikethrough") == "1",
		italic = vim.fn.synIDattr(group_id, "italic") == "1",
		reverse = vim.fn.synIDattr(group_id, "reverse") == "1",
		nocombine = vim.fn.synIDattr(group_id, "nocombine") == "1",
		ctermfg = vim.fn.synIDattr(group_id, "ctermfg"),
		ctermbg = vim.fn.synIDattr(group_id, "ctermbg")
	}
end
_M.get_width = get_width;
_M.set_highlight = set_highlight;
_M.get_hl_group = get_hl_group
return _M
