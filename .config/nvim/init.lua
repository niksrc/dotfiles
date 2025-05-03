vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.title = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.hlsearch = true
vim.opt.showcmd = true
vim.opt.cmdheight = 1
vim.opt.laststatus = 3
vim.opt.expandtab = true
vim.opt.scrolloff = 10
vim.opt.shell = "bash"
vim.opt.inccommand = "split"
vim.opt.ignorecase = true
vim.opt.smarttab = true
vim.opt.breakindent = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.wrap = false
vim.opt.backspace = { "start", "eol", "indent" }
vim.opt.path:append({ "**" })
vim.opt.wildignore:append({ "*/node_modules/*" })
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitright = true -- Put new windows right of current
vim.opt.splitkeep = "cursor"

vim.opt.clipboard:append('unnamed,unnamedplus')

-- Buffers
vim.api.nvim_set_keymap('n', '<leader>bb', ':buffers<CR>', { noremap = true, silent = true })   -- List buffers
vim.api.nvim_set_keymap('n', '<leader>bn', ':bnext<CR>', { noremap = true, silent = true })     -- Next buffer
vim.api.nvim_set_keymap('n', '<leader>bp', ':bprevious<CR>', { noremap = true, silent = true }) -- Previous buffer
vim.api.nvim_set_keymap('n', '<leader>bd', ':bd<CR>', { noremap = true, silent = true })        -- Delete buffer

-- Windows
vim.api.nvim_set_keymap('n', '<leader>ws', ':split<CR>', { noremap = true, silent = true })  -- Horizontal split
vim.api.nvim_set_keymap('n', '<leader>wv', ':vsplit<CR>', { noremap = true, silent = true }) -- Vertical split
vim.api.nvim_set_keymap('n', '<leader>wq', ':q<CR>', { noremap = true, silent = true })      -- Close current window
vim.api.nvim_set_keymap('n', '<leader>wo', ':only<CR>', { noremap = true, silent = true })   -- Close all windows except current

-- Window navigation (Standard Neovim commands)
vim.api.nvim_set_keymap('n', '<C-w>h', '<C-w>h', { noremap = true, silent = true }) -- Move to the left window
vim.api.nvim_set_keymap('n', '<C-w>j', '<C-w>j', { noremap = true, silent = true }) -- Move to the window below
vim.api.nvim_set_keymap('n', '<C-w>k', '<C-w>k', { noremap = true, silent = true }) -- Move to the window above
vim.api.nvim_set_keymap('n', '<C-w>l', '<C-w>l', { noremap = true, silent = true }) -- Move to the right window

-- Tabs (Standard Neovim commands)
vim.api.nvim_set_keymap('n', '<leader>tn', ':tabnew<CR>', { noremap = true, silent = true })      -- Open new tab
vim.api.nvim_set_keymap('n', '<leader>tp', ':tabprevious<CR>', { noremap = true, silent = true }) -- Switch to the previous tab
vim.api.nvim_set_keymap('n', '<leader>tn', ':tabnext<CR>', { noremap = true, silent = true })     -- Switch to the next tab
vim.api.nvim_set_keymap('n', '<leader>tc', ':tabclose<CR>', { noremap = true, silent = true })    -- Close current tab
vim.api.nvim_set_keymap('n', '<leader>tl', ':tabs<CR>', { noremap = true, silent = true })        -- List tabs

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath,
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        { "nvim-lua/plenary.nvim" },
        {
            'sainnhe/gruvbox-material',
            lazy = false,
            priority = 1000,
            config = function()
                -- Optionally configure and load the colorscheme
                -- directly inside the plugin declaration.
                vim.g.gruvbox_material_enable_italic = true
                vim.cmd.colorscheme('gruvbox-material')
            end
        },
        { "nvim-lualine/lualine.nvim" },

        {
            "stevearc/oil.nvim",
            opts = {},
            keys = {
                { "-", "<CMD>Oil<CR>", desc = "Open parent directory" }
            }
        },
        {
            "nvim-telescope/telescope.nvim",
            tag = "0.1.8",
            dependencies = {
                "nvim-lua/plenary.nvim",
                {
                    "nvim-telescope/telescope-fzf-native.nvim",
                    build = "make",
                    config = function()
                        require("telescope").load_extension("fzf")
                    end,
                },
            },
            config = function()
                local builtin = require("telescope.builtin")
                local keymap = vim.keymap.set

                -- Core find operations
                keymap("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
                keymap("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
                keymap("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })
                keymap("n", "<leader>fh", builtin.help_tags, { desc = "Help Tags" })
                keymap("n", "<C-p>", builtin.find_files, {})

                -- Git
                keymap("n", "<leader>gc", builtin.git_commits, { desc = "Git Commits" })
                keymap("n", "<leader>gs", builtin.git_status, { desc = "Git Status" })

                -- LSP
                keymap("n", "<leader>lr", builtin.lsp_references, { desc = "LSP References" })
                keymap("n", "<leader>ld", builtin.lsp_definitions, { desc = "LSP Definitions" })
                keymap("n", "<leader>li", builtin.lsp_implementations, { desc = "LSP Implementations" })
                keymap("n", "<leader>ls", builtin.lsp_document_symbols, { desc = "Document Symbols" })

                -- Misc
                keymap("n", "<leader>fk", builtin.keymaps, { desc = "Keymaps" })
                keymap("n", "<leader>fo", builtin.oldfiles, { desc = "Recent Files" })
                keymap("n", "<leader>fm", builtin.man_pages, { desc = "Man Pages" })
            end,
        },
        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            config = function()
                require("nvim-treesitter.configs").setup({
                    ensure_installed = {
                        "bash", "c", "cpp", "css", "diff", "dockerfile", "gitcommit", "gitignore",
                        "go", "gomod", "gosum", "graphql", "html", "http", "java", "javascript",
                        "jsdoc", "json", "lua", "make", "markdown", "markdown_inline", "python",
                        "regex", "rust", "sql", "toml", "tsx", "typescript", "vim", "vimdoc", "xml",
                        "yaml"
                    },
                    auto_install = true,
                    highlight = {
                        enable = true,
                        disable = function(_, buf)
                            local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
                            return ok and stats and stats.size > 100 * 1024
                        end,
                        additional_vim_regex_highlighting = false,
                    },
                })
            end,
        },
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        {
            "neovim/nvim-lspconfig",
            config = function()
                require("mason").setup()
                -- Define LSP servers to install and configure
                local servers = {
                    "lua_ls", "rust_analyzer", "pyright", "ts_ls", "gopls",
                    "clangd"
                }

                -- Automatically install LSP servers
                require("mason-lspconfig").setup({
                    ensure_installed = servers,
                })


                local lspconfig = require("lspconfig")
                local capabilities = vim.lsp.protocol.make_client_capabilities()
                capabilities = vim.tbl_deep_extend("force", capabilities, {
                    textDocument = {
                        completion = { completionItem = { snippetSupport = true } }
                    }
                })

                local lsp_flags = { debounce_text_changes = 50 }

                for _, server in ipairs(servers) do
                    lspconfig[server].setup({
                        capabilities = capabilities,
                        flags = lsp_flags,
                    })
                end

                -- Diagnostics keymaps
                local diag_opts = { noremap = true, silent = true }
                vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, diag_opts)
                vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, diag_opts)
                vim.keymap.set("n", "]d", vim.diagnostic.goto_next, diag_opts)
                vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, diag_opts)

                vim.api.nvim_create_autocmd("LspAttach", {
                    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                    callback = function(ev)
                        local opts = { buffer = ev.buf }
                        vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
                        local map = vim.keymap.set
                        map("n", "gD", vim.lsp.buf.declaration, opts)
                        map("n", "gd", vim.lsp.buf.definition, opts)
                        map("n", "K", vim.lsp.buf.hover, opts)
                        map("n", "gi", vim.lsp.buf.implementation, opts)
                        map("n", "<C-k>", vim.lsp.buf.signature_help, opts)
                        map("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
                        map("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
                        map("n", "<space>wl", function()
                            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                        end, opts)
                        map("n", "<space>D", vim.lsp.buf.type_definition, opts)
                        map("n", "<space>rn", vim.lsp.buf.rename, opts)
                        map({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
                        map("n", "gr", vim.lsp.buf.references, opts)
                        map("n", "<space>f", function()
                            vim.lsp.buf.format({ async = true })
                        end, opts)
                    end,
                })
            end,
        },
        {
            "stevearc/conform.nvim",
            config = function()
                require("conform").setup({
                    formatters_by_ft = {
                        lua = { "stylua" },
                        python = { "ruff" },
                        javascript = { "prettierd", "prettier" },
                        typescript = { "prettierd", "prettier" },
                        rust = { "rustfmt", "cargo" },
                        go = { "gofmt", "goimports" },
                        yaml = { "prettier" },
                        markdown = { "prettier" },
                        html = { "prettier" },
                        json = { "prettier" },
                        terraform = { "terraform_fmt" },
                        css = { "prettier" },
                        scss = { "prettier" },
                        toml = { "taplo" },
                        sh = { "shfmt" },
                        markdown_inline = { "prettier" },
                    },
                    format_on_save = function(bufnr)
                        local fallback = {
                            lsp_fallback = true,
                            timeout_ms = 500,
                        }
                        return fallback
                    end,
                })
            end,
        },
    },
    checker = { enabled = false },
})
