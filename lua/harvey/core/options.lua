vim.opt.number = true
vim.g.maplocalleader = ","
vim.opt.mouse = "a"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.cursorline = true
vim.opt.relativenumber = true
vim.opt.termguicolors = false
vim.o.winborder = "single"
vim.opt.clipboard = "unnamedplus"

vim.diagnostic.config({
	virtual_text = false, -- hide inline text; use Trouble/float instead
	underline = true,
	signs = true,
	severity_sort = true,
	update_in_insert = false,
})

-- Colored, wavy underlines per severity.
local function set_diag_underlines()
	local diag_colors = {
		Error = "#ff5f5f", -- red
		Warn = "#ffdd57", -- yellow
		Info = "#d0d0d0", -- white/neutral
		Hint = "#9cdcfe", -- soft blue
	}
	for severity, color in pairs(diag_colors) do
		vim.api.nvim_set_hl(0, "DiagnosticUnderline" .. severity, {
			undercurl = true, -- wavy underline (Ghostty supports this)
			underline = false,
			sp = color, -- underline color
			fg = color, -- fallback coloring if underline color not supported
		})
	end
end

set_diag_underlines()
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = set_diag_underlines, -- reapply if theme overwrites highlights
})
