return {
  -- drag and drop / paste images
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      default = {
        dir_path = "assets",
        relative_to_current_file = true,
        prompt_for_file_name = false,
        drag_and_drop = {
          enabled = true,
          insert_mode = true,
        },
      },
      filetypes = {
        markdown = {
          url_encode_path = true,
          template = "![$CURSOR]($FILE_PATH)",
        },
      },
    },
    keys = {
      { "<leader>ip", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard" },
    },
  },

  -- inline rendering of images, mermaid, and math
  {
    "folke/snacks.nvim",
    opts = {
      image = {
        enabled = true,
        doc = { inline = true, float = true },
      },
    },
  },
}
