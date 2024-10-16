// Context menu and context menu accessories

export function get_width(lines) {
    let len = 0;
    for (let line of lines) {
        if (line.length > len) len = line.length;
    }
    return len + 1;
}

export function set_highlight(group, style) {
    if (type(style) == "string") {
        new vim.api.nvim_set_hl(0, group, { link: style });
    } else {
        new vim.api.nvim_set_hl(0, group, style);
    }
}

export function get_hl_group(group_name) {
    let group_id = new vim.fn.synIDtrans(new vim.fn.hlID(group_name))
    return {
        fg            : new vim.fn.synIDattr(group_id, "fg#"),
        bg            : new vim.fn.synIDattr(group_id, "bg#"),
        sp            : new vim.fn.synIDattr(group_id, "sp#"),
        bold          : new vim.fn.synIDattr(group_id, "bold") == "1",
        standout      : new vim.fn.synIDattr(group_id, "standout") == "1",
        underline     : new vim.fn.synIDattr(group_id, "underline") == "1",
        undercurl     : new vim.fn.synIDattr(group_id, "undercurl") == "1",
        underdouble   : new vim.fn.synIDattr(group_id, "underdouble") == "1",
        underdotted   : new vim.fn.synIDattr(group_id, "underdotted") == "1",
        underdashed   : new vim.fn.synIDattr(group_id, "underdashed") == "1",
        strikethrough : new vim.fn.synIDattr(group_id, "strikethrough") == "1",
        italic        : new vim.fn.synIDattr(group_id, "italic") == "1",
        reverse       : new vim.fn.synIDattr(group_id, "reverse") == "1",
        nocombine     : new vim.fn.synIDattr(group_id, "nocombine") == "1",
        ctermfg       : new vim.fn.synIDattr(group_id, "ctermfg"),
        ctermbg       : new vim.fn.synIDattr(group_id, "ctermbg"),
    };
}
