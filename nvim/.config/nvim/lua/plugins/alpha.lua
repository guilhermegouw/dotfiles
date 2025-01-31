return {
  "goolord/alpha-nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- For icons support
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Set your custom ASCII art here
        dashboard.section.header.val = {
        " ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
        " ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
        " ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
        " ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        " ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
        " ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
    }

    -- Add dashboard buttons
    dashboard.section.buttons.val = {
      dashboard.button("e", "📄  New file", ":ene <BAR> startinsert <CR>"),
      dashboard.button("f", "🔍  Find file", ":Telescope find_files<CR>"),
      dashboard.button("r", "🕒  Recent files", ":Telescope oldfiles<CR>"),
      dashboard.button("q", "❌  Quit", ":qa<CR>"),
    }

    -- Footer (optional)
    dashboard.section.footer.val = {
      "May the force be with you ⚡",
    }

    alpha.setup(dashboard.opts)
  end,
}

