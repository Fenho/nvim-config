return {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("tokyonight").setup({
			style = "night",
		})
		-- load the colorscheme here
		vim.cmd([[colorscheme tokyonight]])
	end,
	-- "bluz71/vim-nightfly-guicolors",
	-- priority = 1000, -- make sure to load this before all the other start plugins
	-- config = function()
	-- 	-- load the colorscheme here
	-- 	vim.cmd([[colorscheme nightfly]])
	-- end,
}
