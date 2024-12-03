return {
    {
        "epwalsh/obsidian.nvim",
        version = "*",
        lazy = true,
        ft = 'markdown',
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        opts = {
            workspaces = {
                {
                    name = "zabava",
                    path = "~/GitHub/zabava",
                },
                {
                    name = "personal",
                    path = "/home/alaska/Obsidian Vault",
                },
                {
                    name = "physics",
                    path = "/home/alaska/documents/hse/phys",
                },
            },

            -- see below for full list of options 👇
        },

    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = function() vim.fn["mkdp#util#install"]() end,
    }

}
