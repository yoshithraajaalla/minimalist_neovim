return {
    "goolord/alpha-nvim",
    event = "VimEnter",
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        -- Set header
        dashboard.section.header.val = {
            [[                                                                       ]],
            [[                                                                     ]],
            [[       ████ ██████           █████      ██                     ]],
            [[      ███████████             █████                             ]],
            [[      █████████ ███████████████████ ███   ███████████   ]],
            [[     █████████  ███    █████████████ █████ ██████████████   ]],
            [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
            [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
            [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
            [[                                                                       ]],
        }

        -- Set menu with Nerd Font icons
        dashboard.section.buttons.val = {
            dashboard.button("f", "  Find File          <leader> f f", "<cmd>Telescope find_files<CR>"),
            dashboard.button("g", "  Live Grep          <leader> f g", "<cmd>Telescope live_grep<CR>"),
            dashboard.button("r", "  Recent Files       <leader> f r", "<cmd>Telescope oldfiles<CR>"),
            dashboard.button("b", "  Browse Buffers     <leader> f b", "<cmd>Telescope buffers<CR>"),
            dashboard.button("n", "  New File           n / i", "<cmd>enew<CR>"),
            dashboard.button("e", "  Toggle Nvimtree    <C-n>", "<cmd>NvimTreeToggle<CR>"),
            dashboard.button("?", "  Show all keymaps   ?", "<cmd>Telescope keymaps<CR>"),
        }

        -- Set version line (previously footer)
        local v = vim.version()
        local v_string = string.format("v%d.%d.%d", v.major, v.minor, v.patch)
        dashboard.section.footer.val = "Minimal. Intentional. Fast.               Neovim " .. v_string
        dashboard.section.footer.opts.hl = "Special"

        -- Define custom layout order: padding -> header -> padding -> version (footer) -> padding -> buttons
        local opts = dashboard.opts
        opts.layout = {
            { type = "padding", val = 6 },
            dashboard.section.header,
            { type = "padding", val = 2 },
            dashboard.section.footer,
            { type = "padding", val = 2 },
            dashboard.section.buttons,
        }

        -- Send config to alpha
        alpha.setup(opts)

        -- Disable folding and set 'i' shortcut on alpha buffer
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "alpha",
            callback = function()
                vim.opt_local.foldenable = false
                vim.keymap.set("n", "i", "<cmd>enew | startinsert<cr>", { buffer = true, silent = true, nowait = true })
                vim.keymap.set("n", "<C-n>", "<cmd>NvimTreeToggle<cr>", { buffer = true, silent = true, nowait = true })
                vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>",
                    { buffer = true, silent = true, nowait = true })
                vim.keymap.set("n", "<leader>fw", "<cmd>Telescope live_grep<cr>",
                    { buffer = true, silent = true, nowait = true })
            end,
        })
    end,
}
