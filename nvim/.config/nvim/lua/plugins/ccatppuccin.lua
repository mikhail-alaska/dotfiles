return {
    {
        "catppuccin/nvim",
        lazy = false,
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                transparent_background = true,
                integrations = {
                    nvimtree = true,
                    treesitter = true,
                },
                color_overrides = {
                    all = {
                        surface1 = "#11111b",
                    },
                },
            })
            vim.cmd.colorscheme "catppuccin-mocha"
        end
    },
    opts = {
        -- regular opts
    },
    config = function(_, opts)
        require('notify').setup(vim.tbl_extend('keep', {
            -- other stuff
            background_colour = "#000000"
        }, opts))
    end
}
