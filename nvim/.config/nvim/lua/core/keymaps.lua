local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- General keymaps
map("n", "<leader>w", ":w<CR>", opts) -- Save
map("n", "<leader>q", ":q<CR>", opts) -- Quit
map("n", "<leader>h", ":nohlsearch<CR>", opts) -- Clear search highlight
map("i", "jj", "<Esc>")

-- File Explorer
map("n", "<leader>e", ":NvimTreeToggle<CR>", opts) -- Toggle nvim-tree
map("n", "<leader>r", ":NvimTreeRefresh<CR>", opts) -- Refresh nvim-tree
map("n", "<leader>n", ":NvimTreeFindFile<CR>", opts) -- Find current file in nvim-tree

-- Telescope keymaps
map("n", "<leader>ff", ":Telescope find_files<CR>", opts) -- Find files
map("n", "<leader>fg", ":Telescope live_grep<CR>", opts) -- Live grep
map("n", "<leader>fb", ":Telescope buffers<CR>", opts) -- List buffers
map("n", "<leader>fh", ":Telescope help_tags<CR>", opts) -- Help tags

-- Vertical split with leader + |
map("n", "<leader>|", ":vsplit<CR>", opts)
-- Horizontal split with leader + -
map("n", "<leader>-", ":split<CR>", opts)

