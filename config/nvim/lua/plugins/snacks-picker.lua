-- AIDEV-NOTE: Configure snacks.nvim picker to include hidden files in searches
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        files = {
          hidden = true,
          ignored = false,
        },
        grep = {
          hidden = true,
          ignored = false,
        },
        explorer = {
          hidden = true,
          ignored = false,
        },
      },
    },
  },
}
