return {
  "SunnyTamang/neodoc.nvim",
  ft = "python", -- lazy-load only for Python files
  config = function()
    require("neodoc").setup({
      docstring_style = "google", -- You can change to "numpy" or "sphinx" if needed
      enable_keymaps = true,
      keymap = "<leader>d", -- You can customize this
      use_custom_template = false, -- set to true if you want to edit templates later
    })
  end,
}

