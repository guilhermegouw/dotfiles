return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "macchiato",
      transparent_background = true,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = {
          enabled = true,
          transparent_panel = true,
        },
        treesitter = true,
        notify = true,
        mini = {
          enabled = true,
          indentscope_color = "",
        },
      },
    })
    vim.cmd.colorscheme("catppuccin")
  end,
}
