return {
  "folke/sidekick.nvim",
  opts = {
    -- add any options here
    cli = {
      mux = {
        backend = "tmux",
        enabled = true,
      },
    },
    nes = {
      enabled = true,
      debounce = 200,
    },
  },
}
