-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
--
vim.env.PATH = vim.fn.expand("~/.local/share/npm/bin") .. ":" .. vim.env.PATH

-- OSC52: yank over SSH into local terminal clipboard (no X11/xclip needed)
vim.opt.clipboard = "unnamedplus"
vim.g.clipboard = "osc52"
