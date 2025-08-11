return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local nvimtree = require('nvim-tree')

		-- recommended settings from nvim-tree documentation
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1
		
		-- 
		vim.cmd([[ highlight NvimTreeIndentMarker guifg=#3FC5FF ]])
		
		--config nvim-tree
		nvimtree.setup({
			view = {
				width = 40
			},
			-- change folder arrow icons
			renderer = {
				icons = {
					glyphs = {
						folder = {
							arrow_closed = "→",
							arrow_open = "↓",
						},
					},
				},
			},
			actions = {
				open_file = {
					window_picker = {
						enable = false
					},
				},
			},
			filters = {
				custom = { ".DS_STORE" },
			},
			git = {
				ignore = false
			},
		})

		local keymap = vim.keymap

		keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>")
		keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindToggle<CR>")
		keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>")
		keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>")

	end
}
