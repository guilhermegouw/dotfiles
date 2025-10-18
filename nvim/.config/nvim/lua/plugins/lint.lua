return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      
      lint.linters_by_ft = {
        python = { "flake8" },
      }
      
      -- Configure flake8 to use project's .venv
      lint.linters.flake8.cmd = function()
        local cwd = vim.fn.getcwd()
        local venv_flake8 = cwd .. "/.venv/bin/flake8"
        if vim.fn.executable(venv_flake8) == 1 then
          return venv_flake8
        end
        return "flake8"
      end
      
      -- Auto-run linter
      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  }
