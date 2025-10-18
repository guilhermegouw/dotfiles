return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview" },
  },
  config = function()
    require("diffview").setup({
      use_icons = true,
      enhanced_diff_hl = true,
      keymaps = {
        view = {
          ["q"] = "<cmd>DiffviewClose<cr>",
          ["<C-j>"] = "[c", -- jump to next change
          ["<C-k>"] = "]c", -- jump to previous change
        },
      },
      merge_tool = {
        layout = "diff3_mixed", -- Three-panel layout: local | merged | remote
        disable_diagnostics = true, -- Avoid LSP noise during merges
      },
    })
  end,
}
