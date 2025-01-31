return {
  "jose-elias-alvarez/null-ls.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      sources = {
        -- Black for formatting
        null_ls.builtins.formatting.black,
        -- isort for import sorting
        null_ls.builtins.formatting.isort,
        -- flake8 for linting
        null_ls.builtins.diagnostics.flake8,
      },
      on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
          -- Format on save
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ async = false })
            end,
          })
        end
      end,
    })
  end,
}

