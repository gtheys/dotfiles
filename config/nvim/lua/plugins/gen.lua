return {
  "David-Kunz/gen.nvim",
  opts = {
    model = "deepseek-coder-v2",
    display_mode = "float", -- The display mode. Can be "float" or "split".
    debug = true,
    show_model = true,
    init = function() end,
  },
  keys = {
    {
      "<leader>il",
      function()
        require("gen").select_model()
      end,
      desc = "Select model for LLM",
    },
    { mode = { "n", "v" }, "<leader>ia",  ":Gen Ask<CR>",                      desc = "A[I] [A]sk" },
    { mode = { "n", "v" }, "<leader>ih",  ":Gen Chat<CR>",                     desc = "A[I] C[h]at" },
    { mode = { "n", "v" }, "<leader>iew", ":Gen Enhance_Wording<CR>",          desc = "A[I] [E]nhance [W]ording" },
    { mode = { "n", "v" }, "<leader>ieg", ":Gen Enhance_Grammar_Spelling<CR>", desc = "A[I] [E]nhance [G]rammar" },
    { mode = { "n", "v" }, "<leader>ig",  ":Gen Generate<CR>",                 desc = "A[I] [G]enerate" },
    { mode = { "n", "v" }, "<leader>is",  ":Gen Summarize<CR>",                desc = "A[I] [S]ummarize" },
  },
}
