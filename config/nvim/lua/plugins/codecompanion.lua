local prefix = "<leader>a"

return {
  {
    "olimorris/codecompanion.nvim",
    cmd = { "CodeCompanion", "CodeCompanionActions", "CodeCompanionToggle", "CodeCompanionAdd", "CodeCompanionChat" },
    opts = {
      strategies = {
        chat = {
          adapter = "ollama",
          roles = {
            llm = "  CodeCompanion",
            user = "  User",
          },
          keymaps = {
            close = { modes = { n = "q", i = "<C-c>" } },
            stop = { modes = { n = "<C-c>" } },
          },
        },
        inline = { adapter = { adapter = "ollama" } },
        agent = { adapter = { adapter = "ollama" } },
      },
    },
    keys = {
      { prefix .. "a",  "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "Action Palette" },
      { prefix .. "ac", "<cmd>CodeCompanionChat<cr>",    mode = { "n", "v" }, desc = "New Chat" },
      { prefix .. "aA", "<cmd>CodeCompanionAdd<cr>",     mode = "v",          desc = "Add Code" },
      { prefix .. "ai", "<cmd>CodeCompanion<cr>",        mode = "n",          desc = "Inline Prompt" },
      { prefix .. "aC", "<cmd>CodeCompanionToggle<cr>",  mode = "n",          desc = "Toggle Chat" },
    },
  },
  --- TODO: it is in the which key menu but doesnt show name or icon
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { prefix, group = "ai", icon = "󱚦 " },
      },
    },
  },
  {
    "folke/edgy.nvim",
    optional = true,
    opts = function(_, opts)
      opts.right = opts.right or {}
      table.insert(opts.right, {
        ft = "codecompanion",
        title = "CodeCompanion",
        size = { width = 70 },
      })
    end,
  },
}
