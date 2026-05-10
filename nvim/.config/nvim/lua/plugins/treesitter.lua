return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local config = require("nvim-treesitter.configs")
      config.setup({
        ensure_installed = {"c", "go", "lua", "vim", "vimdoc", "query", "cpp", "python", "markdown", "markdown_inline"},
        auto_install = true,
        highlight = {
          enable = true,
          disable = { "markdown", "markdown_inline" },
        },
        indent = {
          enable = true,
          disable = { "markdown" },
        },
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "vimwiki" },
        callback = function(args)
          pcall(vim.treesitter.stop, args.buf)
        end,
      })
    end
  }
}
