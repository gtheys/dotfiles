return {
  "Davidyz/VectorCode",
  -- pin the nvim plugin to the latest release for stability
  version = "*",
  -- keep the CLI up to date so that it supports the features needed by the lua binding
  build = "uv tool install --upgrade vectorcode",
  dependencies = { "nvim-lua/plenary.nvim" },
}
