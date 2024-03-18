function format_with_null_ls(bufnr)
	vim.lsp.buf.format({
		filter = function(client)
			-- only use null-ls for formatting instead of lsp server
			return client.name == "null-ls"
		end,
		bufnr = bufnr,
	})
end
return {
	"nvimtools/none-ls.nvim", -- configure formatters & linters
	lazy = true,
	event = { "BufReadPre", "BufNewFile" }, -- to enable uncomment this
	dependencies = {
		"jay-babu/mason-null-ls.nvim",
	},
	config = function()
		local mason_null_ls = require("mason-null-ls")

		local null_ls = require("null-ls")

		local null_ls_utils = require("null-ls.utils")

		mason_null_ls.setup({
			ensure_installed = {
				"prettier", -- prettier formatter
				"stylua", -- lua formatter
				"black", -- python formatter
				"pylint", -- python linter
				"eslint_d", -- js linter
				"rubocop",
        "volar"
			},
			automatic_installation = true,
		})

		-- for conciseness
		local formatting = null_ls.builtins.formatting -- to setup formatters
		local diagnostics = null_ls.builtins.diagnostics -- to setup linters

		-- to setup format on save
		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

		-- configure null_ls
		null_ls.setup({
			-- add package.json as identifier for root (for typescript monorepos)
			root_dir = null_ls_utils.root_pattern(".null-ls-root", "Makefile", ".git", "package.json"),
			-- setup formatters & linters
			sources = {
				--  to disable file types use
				--  "formatting.prettier.with({disabled_filetypes: {}})" (see null-ls docs)
				formatting.prettier.with({
					extra_filetypes = { "svelte" },
					-- disabled_filetypes = { "vue", "js" },
					condition = function(utils)
						return utils.root_has_file({
							".prettierrc",
							".prettierrc.json",
							".prettierrc.yaml",
							".prettierrc.yml",
							".prettierrc.js",
							".prettierrc.cjs",
							".prettierrc.config.js",
							".prettierrc.config.cjs",
						})
					end,
				}), -- js/ts formatter
        formatting.eslint.with({
          condition = function(utils)
            return utils.root_has_file({ ".eslintrc.js", ".eslintrc.cjs" }) and not utils.root_has_file({
							".prettierrc",
							".prettierrc.json",
							".prettierrc.yaml",
							".prettierrc.yml",
							".prettierrc.js",
							".prettierrc.cjs",
							".prettierrc.config.js",
							".prettierrc.config.cjs",
						})
          end,
        }),
				formatting.stylua, -- lua formatter
				formatting.isort,
				formatting.black,
				formatting.rubocop,
				diagnostics.lua_ls,
				diagnostics.pylint,
        diagnostics.volar,
				diagnostics.eslint_d.with({ -- js/ts linter
					condition = function(utils)
						return utils.root_has_file({ ".eslintrc.js", ".eslintrc.cjs" }) -- only enable if root has .eslintrc.js or .eslintrc.cjs
					end,
				}),
				diagnostics.rubocop,
			},
			-- configure format on save
			on_attach = function(current_client, bufnr)
				if current_client.supports_method("textDocument/formatting") then
					vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
					vim.api.nvim_set_keymap(
						"n",
						"<space>fm",
						"<cmd>lua format_with_null_ls()<CR>",
						{ noremap = true, silent = true }
					)
					-- vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>fm", "<cmd>lua vim.lsp.buf.format()<CR>", {})
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = augroup,
						buffer = bufnr,
						callback = function()
							format_with_null_ls(bufnr)
						end,
					})
				end
			end,
		})
	end,
}
