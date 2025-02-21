return {
  {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        transparent_background = false,
        integrations = {
            nvimtree = true,
            treesitter = true,
        },
        --color_overrides = {
         --   all = {
          --      surface1 = "#11111b",
           --     },
        --},
      })
      vim.cmd.colorscheme "catppuccin-mocha"
    end
  }
}
