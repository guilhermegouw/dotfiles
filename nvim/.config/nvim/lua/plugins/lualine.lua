return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- Define the Catppuccin palette
    local colors = {
      bg = "#24273a", -- Background (theme bg)
      fg = "#cad3f5", -- Foreground (text)
      cyan = "#91d7e3", -- Cyan
      black = "#1e2030", -- Black
      gray = "#363a4f", -- Gray
      magenta = "#c6a0f6", -- Magenta
      pink = "#f5bde6", -- Pink (Normal mode)
      red = "#ed8796", -- Red
      green = "#a6da95", -- Green (Insert mode)
      yellow = "#eed49f", -- Yellow
      blue = "#8aadf4", -- Blue
      orange = "#f5a97f", -- Orange (Visual mode)
      black4 = "#5b6078" -- Black4
    }
 
    -- Define custom separators
    local separators = {
      left_round = "", -- Round separator
      right_square = "█", -- Square separator
    }

    -- Define the custom theme for lualine
    local custom_theme = {
      normal = {
        a = { fg = colors.black, bg = colors.pink, gui = "bold" }, -- Normal mode
        b = { fg = colors.fg, bg = colors.bg }, -- Neutral style for other sections
        c = { fg = colors.fg, bg = colors.bg }, -- Neutral style
      },
      insert = {
        a = { fg = colors.black, bg = colors.green, gui = "bold" }, -- Insert mode
        b = { fg = colors.fg, bg = colors.bg },
        c = { fg = colors.fg, bg = colors.bg },
      },
      visual = {
        a = { fg = colors.black, bg = colors.blue, gui = "bold" }, -- Visual mode
        b = { fg = colors.fg, bg = colors.bg },
        c = { fg = colors.fg, bg = colors.bg },

      },
      replace = {
        a = { fg = colors.black, bg = colors.red, gui = "bold" }, -- Replace mode
        b = { fg = colors.fg, bg = colors.bg },
        c = { fg = colors.fg, bg = colors.bg },

      },
      command = {
        a = { fg = colors.black, bg = colors.orange, gui = "bold" }, -- Command mode
        b = { fg = colors.fg, bg = colors.bg },
        c = { fg = colors.fg, bg = colors.bg },

      },
      inactive = {
        a = { fg = colors.gray, bg = colors.bg, gui = "bold" }, -- Inactive
        b = { fg = colors.fg, bg = colors.bg },
        c = { fg = colors.fg, bg = colors.bg },
      },
    }

    -- Configure lualine
    require("lualine").setup({
      options = {
        theme = custom_theme,
        section_separators = { left = "", right = "" }, -- Remove separators
        component_separators = { left = "", right = "" }, -- Remove component separators
      },
      sections = {
          -- Mode section (rectangle)
        lualine_a = { { "mode", fmt = function(mode)
          if mode == "NORMAL" then return " NORMAL"
          elseif mode == "INSERT" then return " INSERT"
          elseif mode == "VISUAL" then return " VISUAL"
          end
          return mode
        end } },
        -- Left section (branch, filename)
        lualine_b = { "branch" },
        lualine_c = { "filename" },
        -- Right section (encoding, filetype, position, etc.)
        lualine_x = { 
          { "encoding", separator = { left = separators.left_round, right = "" } }, -- Round on the left
          { "filetype", separator = { left = separators.left_round, right = separators.right_square } }, -- Square on the right
        },
        lualine_y = {
          { "progress", separator = { left = separators.left_round, right = "" } }, -- Progress
        },
        lualine_z = { 
          { "location", separator = { left = separators.left_round, right = separators.right_square } }, -- Square on the right
        },
      },
    })
  end,
}

