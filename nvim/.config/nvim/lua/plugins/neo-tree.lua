return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
    opts = {
      filesystem = {
        filtered_items = {
       visible = true,
       show_hidden_count = true,
       hide_dotfiles = false,
       hide_gitignored = true,
       hide_by_name = {
         -- '.git',
         -- '.DS_Store',
         -- 'thumbs.db',
       },
      never_show = {},
        },
      }
    },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function(_, opts)
		require("neo-tree").setup(opts)
		vim.keymap.set("n", "<C-n>", ":Neotree filesystem toggle left<CR>", {})
		vim.keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>", {})
	end,
}
