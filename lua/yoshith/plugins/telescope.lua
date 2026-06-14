return {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        require("telescope").setup({
            defaults = {
                prompt_prefix = "   ",
                selection_caret = "  ",
                layout_strategy = "horizontal",
                layout_config = { prompt_position = "top", preview_width = 0.55 },
                sorting_strategy = "ascending",
                winblend = 0,
                file_ignore_patterns = { "node_modules", ".git/", "__pycache__", "%.pyc" },
            },
        })
    end,
}
