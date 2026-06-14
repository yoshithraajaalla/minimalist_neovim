return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = true,
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    keys = {
        { "<C-n>", "<cmd>NvimTreeToggle<cr>", desc = "File tree: toggle (C-n per CONTEXT)" },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1

        require("nvim-tree").setup({
            renderer = {
                group_empty = true,
                highlight_git = true,
                indent_markers = { enable = true },
                icons = {
                    show = { git = true, file = true, folder = true },
                    glyphs = { git = { unstaged = "✦", staged = "✔", untracked = "★", deleted = "✘", ignored = "◌" } },
                },
            },
            hijack_cursor = true,
            sync_root_with_cwd = true,
            respect_buf_cwd = true,
            git = { enable = true, ignore = false, timeout = 400 },
            diagnostics = { enable = true, show_on_dirs = true, icons = { error = "●", warning = "●", hint = "●", info = "●" } },
            view = { width = 32, side = "left", preserve_window_proportions = true },
            filters = { dotfiles = false, custom = { "^.git$" } },
            actions = { open_file = { quit_on_open = false, resize_window = false, window_picker = { enable = true } } },
            on_attach = function(bufnr)
                local api = require("nvim-tree.api")
                local function opts(desc)
                    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                end
                api.config.mappings.default_on_attach(bufnr)
                vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
                vim.keymap.set("n", "s", api.node.open.horizontal, opts("Open: Horizontal Split"))
            end,
        })
    end,
}
