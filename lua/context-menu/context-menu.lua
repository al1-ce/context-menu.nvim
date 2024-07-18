local MenuItem = require("context-menu.domain.menu-item")
local MenuItems = require("context-menu.domain.menu-items")
local Utils = require("context-menu.utils")

local M = {}

---@class ContextMenu.Context
---@field buffer number
---@field window number
---@field line string content of current line when trigger the menu
---@field ft string filetype
---@field filename string
---@field menu_buffer_stack number[]
---@field menu_window_stack number[]
---@field menu_buffer number?
---@field menu_window number?

---@param table table
---@param value any
---@return boolean
local function table_contains(table, value)
  if not table then
    return false
  end
  for _, v in pairs(table) do
    if v == value then
      return true
    end
  end
  return false
end

---@param items ContextMenu.Item[]
---@param context ContextMenu.Context
---@return ContextMenu.Item[]
local function filter_items(items, context)
  ---@type ContextMenu.Items
  local filter_by_ft = {}
  for _, item in ipairs(items) do
    if table_contains(item.ft, context.ft) or item.ft == nil then
      table.insert(filter_by_ft, item)
    end
  end

  ---@type ContextMenu.Items
  local filter_by_not_ft = {}
  for _, i in ipairs(filter_by_ft) do
    if not table_contains(i.not_ft, context.ft) then
      table.insert(filter_by_not_ft, i)
    end
  end

  local filter_by_func = {}
  for _, i in ipairs(filter_by_not_ft) do
    if not i.filter_func or i.filter_func(context) then
      table.insert(filter_by_func, i)
    end
  end

  return filter_by_func
end

---order menu_items by the their order field value
---@param menu_items ContextMenu.Item[]
local function reorder_items(menu_items)
  table.sort(menu_items, function(a, b)
    if (not a.order) and b.order then
      return true
    elseif a.order and not b.order then
      return false
    elseif a.order and b.order then
      return a.order > b.order
    else
      return false
    end
  end)
end

---@class ContextMenu.LevelInfo
---@field level number
---@field buf number
---@field win number

---@param context ContextMenu.Context
---@param local_buf_win ContextMenu.LevelInfo
local function trigger_action(context, local_buf_win)
  vim.api.nvim_set_current_buf(local_buf_win.buf)
  local line = vim.api.nvim_get_current_line()

  local selected_cmd = MenuItem.parse(line)

  local item = MenuItems.find_item_by_cmd(selected_cmd.cmd)
  MenuItem.trigger_action(item, local_buf_win, context)
end

---@param context ContextMenu.Context
---@param opts? {}
function prepare_items(context, opts)
  local filtered_items = filter_items(vim.g.context_menu_config.menu_items, context)
  reorder_items(filtered_items)
  return filtered_items
end

---close all menu buffer and window
---@param context ContextMenu.Context
function close_menu(context)
  for _, w in ipairs(context.menu_window_stack) do
    pcall(vim.api.nvim_win_close, w, true)
  end
  for _, b in ipairs(context.menu_buffer_stack) do
    pcall(vim.api.nvim_win_close, b, true)
  end
end

M.close_menu = close_menu

---@param items ContextMenu.Item[]
---@param local_buf_win ContextMenu.LevelInfo
---@param context ContextMenu.Context
local function create_local_keymap(items, local_buf_win, context)
  local function map(lhs, rhs)
    vim.keymap.set({ "v", "n" }, lhs, rhs, {
      noremap = true,
      silent = true,
      nowait = true,
      buffer = local_buf_win.buf,
    })
  end

  map("q", function()
    close_menu(context)
  end)
  map("<ESC>", function()
    close_menu(context)
  end)

  for index, item in ipairs(items) do
    if index < 10 then
      map(tostring(index), function()
        MenuItem.trigger_action(item, local_buf_win, context)
      end)
    end
  end

  map("<CR>", function()
    trigger_action(context, local_buf_win)
  end)
  map("o", function()
    trigger_action(context, local_buf_win)
  end)

  map("g?", function()
    Utils.log("<q> quit; <CR> trigger action under cursor")
  end)
end

---@param menu_items ContextMenu.Item[]
---@param context ContextMenu.Context
---@param opts {level: number}
local function menu_popup_window(menu_items, context, opts)
  local popup_buf = vim.api.nvim_create_buf(false, true)
  local lines = MenuItems.format(menu_items)
  vim.api.nvim_buf_set_lines(popup_buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(popup_buf, "modifiable", false)
  local width = Utils.get_width(lines)
  local height = #menu_items

  local win_opts = {
    relative = "cursor",
    row = 0,
    col = 0,
    width = width + 1,
    height = height,
    style = "minimal",
    border = "single",
    title = "ContextMenu.",
  }

  local win = vim.api.nvim_open_win(popup_buf, true, win_opts)
  table.insert(context.menu_window_stack, win)
  table.insert(context.menu_buffer_stack, popup_buf)

  create_local_keymap(menu_items, {
    buf = popup_buf,
    win = win,
    level = opts.level,
  }, context)
end

M.menu_popup_window = menu_popup_window

function M.trigger_context_menu()
  ---@type ContextMenu.Context
  local context = {
    line = vim.api.nvim_get_current_line(),
    window = vim.api.nvim_get_current_win(),
    buffer = vim.api.nvim_get_current_buf(),
    filename = vim.fn.expand("%:p:t"),
    ft = vim.bo.filetype,
    menu_buffer_stack = {},
    menu_window_stack = {},
  }

  local items = prepare_items(context)

  menu_popup_window(items, context, { level = 1 })
end

return M
