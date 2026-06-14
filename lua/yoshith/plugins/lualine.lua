return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
        local function setup_lualine()
            require("lualine").setup({
                options = {
                    theme = "auto",
                    component_separators = { left = "│", right = "│" },
                    section_separators = { left = "", right = "" },
                    globalstatus = true,
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = { { "filename", path = 1, shorting_target = 40 } },
                    lualine_x = {
                        { "encoding", icons_enabled = false },
                        "filetype",
                    },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
                inactive_sections = {
                    lualine_c = { { "filename", path = 1 } },
                    lualine_x = { "location" },
                },
            })
        end

        setup_lualine()

        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("yoshith_lualine_colorscheme_sync", { clear = true }),
            callback = function()
                setup_lualine()
            end,
        })
    end,
}
