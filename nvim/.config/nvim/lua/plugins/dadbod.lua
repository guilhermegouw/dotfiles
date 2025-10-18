return {
  {
      "tpope/vim-dadbod",
      config = function()
        vim.g.dadbod_manage_dbext = 1
      end,
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      -- Ensure dadbod is loaded
      { "tpope/vim-dadbod", lazy = true },
      -- Optional: Completion support for SQL queries
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    -- Only load these commands when needed
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },
}

