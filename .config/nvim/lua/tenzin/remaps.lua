-- lsp stuff
vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename)
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation)
vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references)
vim.keymap.set('n', 'K', vim.lsp.buf.hover)
vim.keymap.set('n', '<leader>sh', function()
	local function is_clangd_attached(bufnr)
		bufnr = bufnr or vim.api.nvim_get_current_buf()
		for _, client in pairs(vim.lsp.get_active_clients({ bufnr = bufnr })) do
			if client.name == "clangd" then
				return true
			end
		end
		return false
	end

	if is_clangd_attached() then
		vim.cmd("LspClangdSwitchSourceHeader")
	else
		print('clangd not attached')
	end
end)

vim.keymap.set("n", "zi", "za")

-- Format entire buffer
vim.keymap.set("n", "<leader>=", vim.lsp.buf.format)

vim.keymap.set("n", "<C-S>", function()
	vim.cmd("wall")
end)

vim.keymap.set("n", "<C-l>", "xp")
vim.keymap.set("n", "<C-h>", "xhP")

-- Copy selection to clipboard
vim.keymap.set("v", "<leader>y", '"+y')

-- Highlight whole buffer
vim.keymap.set("n", "<leader>%", "ggVG")

-- Copy line to clipboard
vim.keymap.set("n", "<leader>yy", '"+yy')

-- Paste from clipboard
vim.keymap.set("v", "<leader>p", '"+p')
vim.keymap.set("n", "<leader>p", '"+p')

-- Navigate quick fix list
vim.keymap.set("n", "<leader>j", function() vim.cmd("cnext") end)
vim.keymap.set("n", "<leader>k", function() vim.cmd("cprev") end)

-- Navigate one screen line rather than actual line
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

-- paste in insert from unnamed register
vim.keymap.set('i', '<C-f>', '<C-r>"')

-- clears highlight left after searching
vim.keymap.set('n', '<C-c>', function() vim.cmd('nohlsearch') end)

-- center on move
-- vim.keymap.set("n", "n", "nzz")
-- vim.keymap.set("n", "gd", "gdzz")

-- make the window bigger vertically
vim.keymap.set("n", "=", [[<cmd>vertical resize +5<cr>]])
-- make the window smaller vertically
vim.keymap.set("n", "-", [[<cmd>vertical resize -5<cr>]])
-- make the window bigger horizontally by pressing shift and =
vim.keymap.set("n", "+", [[<cmd>horizontal resize +2<cr>]])
-- make the window smaller horizontally by pressing shift and -
vim.keymap.set("n", "_", [[<cmd>horizontal resize -2<cr>]])

-- move in insert with CTRL + h/j/k/l
vim.keymap.set('i', '<C-h>', '<left>')
vim.keymap.set('i', '<C-j>', '<down>')
vim.keymap.set('i', '<C-k>', '<up>')
vim.keymap.set('i', '<C-l>', '<right>')

-- move selection up/ down
vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv=gv")

-- move line up/ down
vim.keymap.set("n", "<C-j>", "V:m '>+1<CR>gv=gv")
vim.keymap.set("n", "<C-k>", "V:m '<-2<CR>gv=gv")

vim.keymap.set('n', 'ZZ', ':wqa!<cr>')
