return {
  "kristijanhusak/vim-dadbod-completion",
  dependencies = "hrsh7th/nvim-cmp",
  ft = { "sql", "mysql", "plsql" },
  config = function()
    require("cmp").setup.filetype({ "sql", "mysql", "plsql" }, {
      sources = {
        { name = "vim-dadbod-completion" },
        { name = "buffer" },
      },
    })
  end,
}
