 return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          python = { "isort", "black" },
        },
        
        format_on_save = {
          timeout_ms = 2000,
          lsp_fallback = true,
        },
        
        -- Configure formatters to use project's .venv
        formatters = {
          black = {
            command = function()
              -- Try to find black in the project's .venv first
              local cwd = vim.fn.getcwd()
              local venv_black = cwd .. "/.venv/bin/black"
              if vim.fn.executable(venv_black) == 1 then
                return venv_black
              end
              return "black"
            end,
          },
          isort = {
            command = function()
              -- Try to find isort in the project's .venv first
              local cwd = vim.fn.getcwd()
              local venv_isort = cwd .. "/.venv/bin/isort"
              if vim.fn.executable(venv_isort) == 1 then
                return venv_isort
              end
              return "isort"
            end,
          },
        },
      })
      
      -- Optional: Add keymap for manual formatting
      vim.keymap.set({ "n", "v" }, "<leader>f", function()
        require("conform").format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 500,
        })
      end, { desc = "Format file or range (in visual mode)" })
    end,
  }
