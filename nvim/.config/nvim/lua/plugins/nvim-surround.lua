return {
  "kylechui/nvim-surround",
  config = function()
    require("nvim-surround").setup({
      keymaps = {
        visual = "sv",
        delete = "sd",
        change = "sc",
      },
      surrounds = {
        ["("] = {
          add = {"(", ")"},
        },
        ["["] = {
          add = {"[", "]"},
        },
        ["{"] = {
          add = {"{", "}"},
        },
      },
    })
  end,
}

