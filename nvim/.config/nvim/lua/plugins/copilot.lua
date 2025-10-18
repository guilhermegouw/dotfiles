return {
  "github/copilot.vim",
  lazy = false, -- loads at startup
  config = function()
    vim.api.nvim_set_keymap("n", "<leader>cp", ":Copilot panel<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>cs", ":Copilot status<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>cd", ":Copilot disable<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>ce", ":Copilot enable<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>ct", ":Copilot toggle<CR>", { noremap = true, silent = true })
  end,
}
