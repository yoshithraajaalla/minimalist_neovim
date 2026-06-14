return {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
        library = {
            { path = "luvit-meta/library", words = { "vim%.uv" } },
            { path = "nvim-lua/plenary.nvim" },
        },
    },
}
