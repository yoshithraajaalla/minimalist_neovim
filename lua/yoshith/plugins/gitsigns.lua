return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("gitsigns").setup({
            signs = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "" },
                topdelete = { text = "" },
                changedelete = { text = "▎" },
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local m = function(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
                end
                m("n", "]h", gs.next_hunk, "Next hunk")
                m("n", "[h", gs.prev_hunk, "Prev hunk")
                m("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
                m("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
                m("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
                m("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
                m("n", "<leader>hd", gs.diffthis, "Diff this")
            end,
        })
    end,
}
