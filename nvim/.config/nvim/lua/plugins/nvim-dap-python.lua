return {
  "mfussenegger/nvim-dap-python",
  dependencies = { 
    "mfussenegger/nvim-dap",
    "rcarriga/nvim-dap-ui" 
  },
  ft = "python",
  config = function()
    local function get_python_path()
      local cwd = vim.fn.getcwd()
      local venv_path = cwd .. "/.venv/bin/python"
      local f = io.open(venv_path, "r")
      if f then
        f:close()
        return venv_path
      end
      local venv = os.getenv("VIRTUAL_ENV")
      if venv then
        return venv .. "/bin/python"
      end
      return vim.fn.exepath("python3") or vim.fn.exepath("python")
    end
    local python_path = get_python_path()
    print("Using Python path for debugging: " .. python_path)
    require("dap-python").setup(python_path)
    vim.keymap.set("n", "<leader>dpt", function()
      require("dap-python").test_method()
    end, { desc = "Debug Python Test Method" })
    vim.keymap.set("n", "<leader>dpc", function()
      require("dap-python").test_class()
    end, { desc = "Debug Python Test Class" })
  end,
}
