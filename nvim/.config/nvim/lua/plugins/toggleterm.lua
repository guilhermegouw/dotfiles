-- lua/plugins/toggleterm.lua

return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      -- Your general settings
      direction = "float",
      on_open = function(term)
        vim.cmd("setlocal NormalFloat guibg=NONE")
      end,

      -- Define persistent terminals here
      terminals = {
        {
          -- This is a table of options, not a list of strings
          id = "gemini",
          cmd = "gemini", -- The actual shell command to run
          display_name = "Gemini CLI",
          direction = "float",
          hidden = true, -- This will start the terminal hidden
          on_open = function(term)
            vim.cmd("setlocal NormalFloat guibg=NONE")
          end,
        },
      },
    })
  end,
}
