local _M = {}

local utils = require("context-menu.utils");
local style = require("context-menu.style");
local log = require("context-menu.log");
local function merge_or_keep(a, b)
	if not b then
		return a
	end;
	return vim.tbl_deep_extend("force", a, b)
end;
local function check_menu_items(items, parent_name)
	do
		local i = 0
		while i < # items do
			local item = items[i + 1];
			if not item.name and not item.separator then
				log.error(string.format([=[Child item of %s no. %s is missing name.]=], parent_name, i + 1));
				return false
			end;
			if not item.cmd and not item.sub_menu then
				log.error(string.format([=[Child item of %s no. %s is missing action (cmd or sub_menu).]=], parent_name, i + 1));
				return false
			end
			i = i + 1
		end
	end;
	return true
end;
local function setup(opts)
	opts = opts or {};
	local conf = vim.deepcopy(vim.g.context_menu_config);
	conf.menu_items = opts.menu_items or conf.menu_items;
	conf.debug = opts.debug or conf.debug;
	conf.window = merge_or_keep(conf.window, opts.window);
	conf.keymap = merge_or_keep(conf.debug, opts.debug);
	utils.set_highlight(style.window_style, conf.window.style);
	utils.set_highlight(style.cursor_style, conf.window.cursor);
	utils.set_highlight(style.border_style, conf.window.border_style);
	if not check_menu_items(conf.menu_items, "Context Menu") then
		conf.menu_items = vim.g.context_menu_config.menu_items
	end;
	vim.g.context_menu_config = conf
end
_M.setup = setup
return _M
