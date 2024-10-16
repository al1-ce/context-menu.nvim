export function error(msg) {
    new vim.api.nvim_err_writeln();
}

export function log(msg) {
    if (vim.g.context_menu_config.debug) {
        // TODO: implement
        // vim.notify(msg);
    }
}

export function trace(what) {
    require("notify")(new vim.inspect(what))
}
