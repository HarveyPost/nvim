return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },
  config = function()
    local mason_lspconfig = require("mason-lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    -- Keymaps set when an LSP client attaches.
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local keymap = vim.keymap
        local opts = { buffer = ev.buf, silent = true }

        opts.desc = "Show LSP references"
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

        opts.desc = "See available code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        opts.desc = "Show buffer diagnostics"
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

        opts.desc = "Go to next diagnostic"
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts)

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
      end,
    })

    -- Use cmp_nvim_lsp capabilities for completion.
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Gutter icons.
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- Helper to build a diagnostics handler that drops only long-line warnings.
    local function longline_filtering_handler(base)
      return function(err, result, ctx, cfg)
        if result and result.diagnostics then
          result = vim.deepcopy(result)
          result.diagnostics = vim.tbl_filter(function(d)
            local code = d.code
            local msg = d.message or ""
            if code == "E501" or code == "line-too-long" or code == "reportLineTooLong" then
              return false
            end
            if msg:match("[Ll]ine%s+too%s+long") then
              return false
            end
            return true
          end, result.diagnostics)
        end
        return base(err, result, ctx, cfg)
      end
    end

    -- Prefer Neovim 0.10+ API; fall back to legacy lspconfig if needed.
    local has_new_api = vim.lsp and vim.lsp.config and vim.lsp.enable
    local lspconfig = nil
    if not has_new_api then
      lspconfig = require("lspconfig")
    end

    local function setup_server(name, opts)
      opts = opts or {}
      if has_new_api then
        local ok = pcall(vim.lsp.config, name, opts)
        if ok then
          pcall(vim.lsp.enable, name)
        end
      elseif lspconfig and lspconfig[name] then
        lspconfig[name].setup(opts)
      end
    end

    mason_lspconfig.setup({})
    local servers = mason_lspconfig.get_installed_servers()
    for _, server_name in ipairs(servers) do
      if server_name == "pyright" then
        setup_server(server_name, {
          capabilities = capabilities,
          handlers = {
            ["textDocument/publishDiagnostics"] = longline_filtering_handler(
              vim.lsp.handlers["textDocument/publishDiagnostics"]
            ),
          },
          settings = {
            python = {
              analysis = {
                disable = { "reportLineTooLong" },
              },
            },
          },
        })
      else
        setup_server(server_name, { capabilities = capabilities })
      end
    end
  end,
}
