return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- For file icons
  config = function()
    local function on_attach(bufnr)
      local api = require("nvim-tree.api")

      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      api.config.mappings.default_on_attach(bufnr)

      vim.keymap.set("n", "ya", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
      vim.keymap.set("n", "yr", api.fs.copy.relative_path, opts("Copy Relative Path"))
    end

    require("nvim-tree").setup({
      on_attach = on_attach,
      view = {
        width = 30,
        side = "left",
      },
      renderer = {
        highlight_git = true,
        icons = {
          show = {
            git = true,
            folder = true,
            file = true,
            folder_arrow = true,
          },
        },
      },
      git = {
        enable = true,
      },
      filters = {
        dotfiles = true, -- Hide dotfiles by default
      },
    })
  end,
}
