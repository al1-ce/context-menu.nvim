local _M = {}

local function error(msg)
	vim.api.nvim_err_writeln()
end;
local function log(msg)
	if vim.g.context_menu_config.debug then
	end
end;
local function trace(what)
	require("notify")(vim.inspect(what))
end
_M.error = error;
_M.log = log;
_M.trace = trace
return _M
