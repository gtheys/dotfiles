return {
  "ravitemer/mcphub.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("mcphub").setup({
      cmd = "npx",
      cmdArgs = { "mcp-hub@latest" },
    })
  end,
}
