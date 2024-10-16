local M = {}
local Item = require("context-menu.domain.menu-item")

local function get_color(group, attr)
    return vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(group)), attr)
end

local function trace(what)
    require("notify")(vim.inspect(what))
end

local function get_hl_group(group)
    local gr_id = vim.fn.synIDtrans(vim.fn.hlID(group))
    return {
        fg = vim.fn.synIDattr(gr_id, "fg#"),
        bg = vim.fn.synIDattr(gr_id, "bg#"),
        sp = vim.fn.synIDattr(gr_id, "sp#"),
        bold = vim.fn.synIDattr(gr_id, "bold") == "1",
        standout = vim.fn.synIDattr(gr_id, "standout") == "1",
        underline = vim.fn.synIDattr(gr_id, "underline") == "1",
        undercurl = vim.fn.synIDattr(gr_id, "undercurl") == "1",
        underdouble = vim.fn.synIDattr(gr_id, "underdouble") == "1",
        underdotted = vim.fn.synIDattr(gr_id, "underdotted") == "1",
        underdashed = vim.fn.synIDattr(gr_id, "underdashed") == "1",
        strikethrough = vim.fn.synIDattr(gr_id, "strikethrough") == "1",
        italic = vim.fn.synIDattr(gr_id, "italic") == "1",
        reverse = vim.fn.synIDattr(gr_id, "reverse") == "1",
        nocombine = vim.fn.synIDattr(gr_id, "nocombine") == "1",
        ctermfg = vim.fn.synIDattr(gr_id, "ctermfg"),
        ctermbg = vim.fn.synIDattr(gr_id, "ctermbg"),
    }
end

---@param bufnr number
local function highlight_current_line(bufnr, ns_id)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row = cursor[1] - 1

    vim.api.nvim_buf_set_extmark(bufnr, ns_id, row, 0, {
        line_hl_group = "CurrentLineContextMenu",
        priority = 101,
    })
end

local function highlight_buffer_lines(menu_items, bufnr, ns_id)
    for i = 0, #menu_items - 1 do
        local line_hl = menu_items[i + 1].hl
        local hl_group = "ContextMenuLineDefault"
        local default_group = get_hl_group(hl_group)
        if line_hl then
            hl_group = "ContextMenuLine" .. tostring(i)
            if type(line_hl) == "string" then
                local line_group = get_hl_group(line_hl)
                line_group.bg = default_group.bg
                line_group.ctermbg = default_group.ctermbg
                vim.api.nvim_set_hl(0, hl_group, line_group)
            else
                ---@diagnostic disable-next-line: param-type-mismatch
                line_hl.bg = default_group.bg
                line_hl.ctermbg = default_group.ctermbg
                vim.api.nvim_set_hl(0, hl_group, line_hl)
            end

        vim.api.nvim_buf_set_extmark(bufnr, ns_id, i, 0, {
            line_hl_group = hl_group,
            priority = 100,
        })
        end
    end
end

---create highlight for current buffer
---@param bufnr any
function M.create_highlight(menu_items, bufnr)
    local ns_id = vim.api.nvim_create_namespace("context_menu_highlight")
    -- Use an autocmd to trigger the highlight when the cursor moves
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        callback = function()
            vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
            highlight_buffer_lines(menu_items, bufnr, ns_id)
            highlight_current_line(bufnr, ns_id)
        end,
        buffer = bufnr, -- Ensure the autocommand is tied to the current buffer
    })
end

return M
