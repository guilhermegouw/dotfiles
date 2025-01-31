return {
  "windwp/nvim-autopairs",
  event = "InsertEnter", -- Load only when entering Insert mode
  config = function()
    require("nvim-autopairs").setup({
      check_ts = true, -- Enable treesitter integration
      fast_wrap = {}, -- Enable <M-e> for fast wrapping
    })

    -- Integration with nvim-cmp (if you're using it)
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    local cmp = require("cmp")
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  end,
} 
