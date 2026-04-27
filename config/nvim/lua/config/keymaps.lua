-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "gd", function()
  vim.lsp.buf.definition({ reuse_win = false })
end)

vim.keymap.set("n", "gD", function()
  vim.lsp.buf.declaration({ reuse_win = false })
end)

vim.keymap.set("n", "gI", function()
  vim.lsp.buf.implementation({ reuse_win = false })
end)
