return {
    "sphamba/smear-cursor.nvim",
    event = "VimEnter",
    opts = {
        stiffness = 0.8,
        trailing_stiffness = 0.6,
        damping = 0.95,
        damping_insert_mode = 0.95,
    },
}
