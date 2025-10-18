return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    { "tpope/vim-dadbod", lazy = true },
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
  },
  cmd = {
    "DBUI",
    "DBUIToggle",
    "DBUIAddConnection",
    "DBUIFindBuffer",
  },
  init = function()
    -- Your DBUI configuration
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_winwidth = 40
    vim.g.db_ui_auto_execute_table_helpers = 1
  end,
  config = function()
    -- Database connections
    vim.g.dbs = {
      sql_tutorial = "sqlite:/home/guilherme/code/sql-10-minutes/TYSQL.sqlite",
      radiopeao_backend = "postgresql://radiopeao:radiopeao123@localhost:5434/radiopeao_dev",
    }
  end,
}
