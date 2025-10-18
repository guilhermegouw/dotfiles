return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui"
  },
  keys = {
    -- Your existing keymaps are fine...
    { "<F5>", function() require("dap").continue() end, desc = "Start/Continue Debugging" },
    { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
    { "<F10>", function() require("dap").step_over() end, desc = "Step Over" },
    { "<F11>", function() require("dap").step_into() end, desc = "Step Into" },
    { "<S-F11>", function() require("dap").step_out() end, desc = "Step Out" },
    { "<F12>", function() require("dap").terminate() end, desc = "Terminate" },
    { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
    { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Conditional Breakpoint" },
    { "<leader>ds", function() require("dap").step_over() end, desc = "Step Over" },
    { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
    { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
    { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
  },
  config = function()
    local dap = require("dap")
    
    -- THIS IS THE MISSING PIECE - ADD THE DEBUGPY ADAPTER
    dap.adapters.python = {
      type = 'executable',
      command = 'python',
      args = { '-m', 'debugpy.dap' },
    }
    
    dap.configurations.python = {
      {
        type = "python",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        pythonPath = function()
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
        end,
      },
      -- ADD DJANGO CONFIGURATION
      {
        type = "python",
        request = "launch",
        name = "Django: runserver",
        program = "${workspaceFolder}/manage.py",
        args = { "runserver", "--noreload" },
        django = true,
        justMyCode = false,
        console = "integratedTerminal",
        pythonPath = function()
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
        end,
      },
    }
    
    -- Your existing event listeners
    dap.listeners.after.initialize["log"] = function()
      vim.notify("Debug session initialized", vim.log.levels.INFO)
    end
    
    dap.listeners.after.event_terminated["log"] = function()
      vim.notify("Debug session terminated", vim.log.levels.WARN)
    end
    
    dap.listeners.after.event_exited["log"] = function(_, exit_code)
      vim.notify("Debug session exited with code: " .. tostring(exit_code), vim.log.levels.WARN)
    end
    
    -- Your existing sign definitions
    vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "DapBreakpoint", linehl = "", numhl = "" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "🔍", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
    vim.fn.sign_define("DapStopped", { text = "▶️", texthl = "DapStopped", linehl = "DapStopped", numhl = "" })
    
    -- Remove JS/TS configs if you don't need them, or keep them
    dap.configurations.javascript = {
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        cwd = "${workspaceFolder}",
      },
    }
    
    dap.configurations.typescript = dap.configurations.javascript
  end,
}
