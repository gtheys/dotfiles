-- AIDEV-NOTE: Disabled in favor of tokyonight-storm colorscheme
return {
	{
		"RRethy/base16-nvim",
		enabled = false,
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#16161e',
				base01 = '#2f3549',
				base02 = '#444b6a',
				base03 = '#2f3549',
				base04 = '#cbccd1',
				base05 = '#73daca',
				base06 = '#73daca',
				base07 = '#387068',
				base08 = '#f7768e',
				base09 = '#bb9af7',
				base0A = '#cbccd1',
				base0B = '#7aa2f7',
				base0C = '#bb9af7',
				base0D = '#7aa2f7',
				base0E = '#bb9af7',
				base0F = '#f7768e',
			})

			local function set_hl_mutliple(groups, value)
				for _, v in pairs(groups) do vim.api.nvim_set_hl(0, v, value) end
			end

			vim.api.nvim_set_hl(0, 'Visual',
				{ bg = '#7dcfff', fg = '#73daca', bold = true })
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#2f3549' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#7aa2f7', bold = true })

			local current_file_path = vim.fn.stdpath("config") .. "/lua/plugins/dankcolors.lua"

			if not _G._matugen_theme_watcher then
				local uv = vim.uv or vim.loop
				_G._matugen_theme_watcher = uv.new_fs_event()

				_G._matugen_theme_watcher:start(current_file_path, {}, vim.schedule_wrap(function()
					local new_spec = dofile(current_file_path)

					if new_spec and new_spec[1] and new_spec[1].config then
						new_spec[1].config()
						print("󰂖 Matugen: Colors reloaded!")
					end
				end))
			end
		end
	}
}
