return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim", -- Required for UI components
    "rcarriga/nvim-notify", -- For notifications
  },
  config = function()
    require("noice").setup({
      cmdline = {
        enabled = true, -- Enable the command line UI
        view = "cmdline_popup", -- Show it as a popup
        format = {
          cmdline = { pattern = "^:", icon = "", lang = "vim" },
          search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
          search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
        },
      },
      popupmenu = {
        enabled = true, -- Enable enhanced popup menu
        backend = "nui",
      },
      messages = {
        enabled = true, -- Show messages in the UI
      },
      lsp = {
        progress = { enabled = true }, -- Show LSP progress
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        command_palette = false, -- You can enable it if you prefer
        long_message_to_split = true,
        inc_rename = false,
      },
    })
  end,
}

