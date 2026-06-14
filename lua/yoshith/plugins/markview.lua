return {
  "OXY2DEV/markview.nvim",
  -- Load after colorscheme for correct highlight groups (per plugin docs).
  -- lazy = false is recommended by the author.
  lazy = false,
  priority = 49, -- lower than koda (1000) so theme applies first
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons", -- for icons in code blocks, links etc. (already present via lualine)
  },
  ---@module "markview"
  ---@type mkv.config
  opts = {
    -- Similar philosophy to the old render-markdown config (keep it clean & focused on Markdown).
    -- You can enable more (typst, latex, html_inline, etc.) later if needed.
    markdown = {
      enable = true,
      -- Headings get nice icons and styling by default.
      -- You can customize per level if desired.
    },
    markdown_inline = {
      enable = true,
    },

    preview = {
      -- Show in normal mode + some others. Hybrid for editing + preview.
      modes = { "n", "no", "c" },
      hybrid_modes = { "n" },

      -- Debounce for smoother updates while typing.
      debounce = 50,

      -- Use the same border style as the rest of the config.
      -- border = "rounded",
    },

    -- Disable things that were turned off before (latex, html, yaml frontmatter clutter).
    -- You can re-enable selectively.
    latex = { enable = false },
    html = { enable = false },
    typst = { enable = false },

    -- If you want to tweak icons or colors, see the full config wiki.
    -- https://github.com/OXY2DEV/markview.nvim/wiki/Markdown
  },

  -- Optional keymaps (scoped to markdown buffers once loaded)
  keys = {
    { "<leader>mv", "<cmd>Markview toggle<cr>", desc = "Toggle Markview (in-buffer)", ft = "markdown" },
    { "<leader>mp", "<cmd>Markview splitToggle<cr>", desc = "Markview split preview", ft = "markdown" },
  },

  config = function(_, opts)
    require("markview").setup(opts)

    -- For our transparent koda theme: re-apply markview highlights after theme changes
    -- (markview registers its own groups; this keeps things looking good on :Theme cycles)
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("yoshith_markview_theme_sync", { clear = true }),
      callback = function()
        -- Re-setup is cheap and ensures highlight links are correct with our cleared Normal bg
        require("markview").setup(opts)
      end,
    })
  end,
}
