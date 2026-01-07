-- Helper functions
local function walk_in_codediff(picker, item)
	local Snacks = require("snacks")
	picker:close()
	if item.commit then
		local current_commit = item.commit

		vim.fn.setreg("+", current_commit)
		vim.notify("Copied: " .. current_commit)
		-- get parent / previous commit
		local parent_commit = vim.trim(vim.fn.system("git rev-parse --short " .. current_commit .. "^"))
		parent_commit = parent_commit:match("[a-f0-9]+")
		-- Check if command failed (e.g., Initial commit has no parent)
		if vim.v.shell_error ~= 0 then
			vim.notify("Cannot find parent (Root commit?)", vim.log.levels.WARN)
			parent_commit = ""
		end
		local cmd = string.format("CodeDiff %s %s", parent_commit, current_commit)
		vim.notify("Diffing: " .. parent_commit .. " -> " .. current_commit)
		vim.cmd(cmd)
	end
end

local function git_pickaxe(opts)
	local Snacks = require("snacks")
	opts = opts or {}
	local is_global = opts.global or false
	local current_file = vim.api.nvim_buf_get_name(0)
	-- Force global if current buffer is invalid
	if not is_global and (current_file == "" or current_file == nil) then
		vim.notify("Buffer is not a file, switching to global search", vim.log.levels.WARN)
		is_global = true
	end

	local title_scope = is_global and "Global" or vim.fn.fnamemodify(current_file, ":t")
	vim.ui.input({ prompt = "Git Search (-G) in " .. title_scope .. ": " }, function(query)
		if not query or query == "" then
			return
		end

		-- set keyword highlight within Snacks.picker
		vim.fn.setreg("/", query)
		local old_hl = vim.opt.hlsearch
		vim.opt.hlsearch = true

		local args = {
			"log",
			"-G" .. query,
			"-i",
			"--pretty=format:%C(yellow)%h%Creset %s %C(green)(%cr)%Creset %C(blue)<%an>%Creset",
			"--abbrev-commit",
			"--date=short",
		}

		if not is_global then
			table.insert(args, "--")
			table.insert(args, current_file)
		end

		Snacks.picker({
			title = 'Git Log: "' .. query .. '" (' .. title_scope .. ")",
			finder = "proc",
			cmd = "git",
			args = args,

			transform = function(item)
				local clean_text = item.text:gsub("\27%[[0-9;]*m", "")
				local hash = clean_text:match("^%S+")
				if hash then
					item.commit = hash
					if not is_global then
						item.file = current_file
					end
				end
				return item
			end,

			preview = "git_show",
			confirm = walk_in_codediff,
			format = "text",

			on_close = function()
				-- remove keyword highlight
				vim.opt.hlsearch = old_hl
				vim.cmd("noh")
			end,
		})
	end)
end

return {
	"esmuellert/vscode-diff.nvim",
	dependencies = { "MunifTanjim/nui.nvim" },
	keys = {
		{
			"<leader>cd",
			":CodeDiff",
			desc = "Open prompt for VSCode-diff view",
		},
		{
			"<leader>cdm",
			function()
				vim.cmd("CodeDiff main")
			end,
			desc = "Open prompt for VSCode-diff view",
		},
		{
			"<leader>cdf",
			":CodeDiff file",
			desc = "Open prompt for VSCode-diff view",
		},
		{
			"<leader>cdd",
			function()
				vim.cmd("CodeDiff")
			end,
			desc = "Open prompt for VSCode-diff view",
		},
		{
			"<leader>hs",
			function()
				git_pickaxe({ global = false })
			end,
			desc = "Git Search (Buffer)",
		},
		{
			"<leader>hS",
			function()
				git_pickaxe({ global = true })
			end,
			desc = "Git Search (Global)",
		},
		{
			"<leader>hl",
			function()
				local Snacks = require("snacks")
				Snacks.picker.git_log_file({
					confirm = walk_in_codediff,
				})
			end,
			desc = "find_git_log_file",
			mode = { "n", "t" },
		},
		{
			"<leader>hL",
			function()
				local Snacks = require("snacks")
				Snacks.picker.git_log({
					confirm = walk_in_codediff,
				})
			end,
			desc = "find_git_log",
			mode = { "n", "t" },
		},
	},
}
