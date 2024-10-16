// Main configuration

let utils = require("context-menu.utils");
let style = require("context-menu.style");
let log   = require("context-menu.log");

// merge b into a or keep a if b is null
function merge_or_keep(a, b) {
    if (!b) return a;
    return new vim.tbl_deep_extend("force", a, b);
}

function check_menu_items(items, parent_name) {
    for (let i = 0; i < items.length; ++i) {
        let item = items[i + 1];
        if (!item.name && !item.separator) {
            new log.error(`Child item of ${parent_name} no. ${i + 1} is missing name.`);
            return false;
        }
        if (!item.cmd && !item.sub_menu) {
            new log.error(`Child item of ${parent_name} no. ${i + 1} is missing action (cmd or sub_menu).`);
            return false;
        }
    }
    return true;
}

export function setup(opts) {
    opts = opts || {}; // FIXME: #9
    let conf = new vim.deepcopy(vim.g.context_menu_config);
    conf.menu_items = opts.menu_items || conf.menu_items;
    conf.debug = opts.debug || conf.debug;
    conf.window = merge_or_keep(conf.window, opts.window);
    conf.keymap = merge_or_keep(conf.debug, opts.debug);

    new utils.set_highlight(style.window_style, conf.window.style);
    new utils.set_highlight(style.cursor_style, conf.window.cursor);
    new utils.set_highlight(style.border_style, conf.window.border_style);

    if (!check_menu_items(conf.menu_items, "Context Menu")) {
        conf.menu_items = vim.g.context_menu_config.menu_items;
    }

    vim.g.context_menu_config = conf;
}
