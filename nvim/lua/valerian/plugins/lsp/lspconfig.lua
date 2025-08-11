return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "hrsh7th/cmp-nvim-lsp" },
  config = function()
    -- Python LSP setup with sensible defaults

    local ok_lspconfig, lspconfig = pcall(require, "lspconfig")
    if not ok_lspconfig then
      vim.notify("nvim-lspconfig not found", vim.log.levels.WARN)
      return
    end

    -- Optional: enhanced capabilities if nvim-cmp is used
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    do
      local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok_cmp and cmp_lsp then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end
    end

    -- Utility: check if a server command is on PATH
    local function is_cmd_available(cmd)
      if type(cmd) == "string" then
        return vim.fn.executable(cmd) == 1
      elseif type(cmd) == "table" and #cmd > 0 then
        return vim.fn.executable(cmd[1]) == 1
      end
      return false
    end

    -- Detect active Python environment and interpreter
    local function detect_python_environment()
      local venv_path = vim.env.VIRTUAL_ENV or vim.env.CONDA_PREFIX
      local is_windows = vim.loop.os_uname().sysname == "Windows_NT"
      local python_bin
      if venv_path then
        python_bin = is_windows and (venv_path .. "\\Scripts\\python.exe") or (venv_path .. "/bin/python")
      end
      if not python_bin or vim.fn.filereadable(python_bin) == 0 then
        python_bin = vim.fn.exepath("python3")
        if python_bin == "" then
          python_bin = vim.fn.exepath("python")
        end
      end

      local venv_dirname, venv_name
      if venv_path and venv_path ~= "" then
        venv_dirname = vim.fn.fnamemodify(venv_path, ":h")
        venv_name = vim.fn.fnamemodify(venv_path, ":t")
      end

      return {
        venv_path = venv_path,
        venv_dirname = venv_dirname,
        venv_name = venv_name,
        python_bin = python_bin,
      }
    end

    local PYENV = detect_python_environment()

    -- Common on_attach with handy keymaps
    local function on_attach(client, bufnr)
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = desc })
      end

      map("n", "gd", vim.lsp.buf.definition, "LSP: Go to definition")
      map("n", "gD", vim.lsp.buf.declaration, "LSP: Go to declaration")
      map("n", "gi", vim.lsp.buf.implementation, "LSP: Go to implementation")
      map("n", "gr", vim.lsp.buf.references, "LSP: List references")
      map("n", "K", vim.lsp.buf.hover, "LSP: Hover")
      map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: Rename symbol")
      map("n", "<leader>ca", vim.lsp.buf.code_action, "LSP: Code action")
      map("n", "<leader>f", function()
        vim.lsp.buf.format({ async = true })
      end, "LSP: Format buffer")

      -- Diagnostics
      map("n", "[d", vim.diagnostic.goto_prev, "Diagnostics: Prev")
      map("n", "]d", vim.diagnostic.goto_next, "Diagnostics: Next")
      map("n", "<leader>e", vim.diagnostic.open_float, "Diagnostics: Float")
      map("n", "<leader>q", vim.diagnostic.setloclist, "Diagnostics: Loclist")
    end

    -- Try to use BasedPyright -> Pyright -> Pylsp
    local function setup_first_available(servers)
      for _, def in ipairs(servers) do
        local name = def.name
        local settings = def.settings or {}
        local cmd = def.cmd

        -- If a custom availability check exists, use it; otherwise, verify the server's cmd is on PATH
        local available
        if def.is_available ~= nil then
          available = def.is_available()
        else
          local default_cmd
          if
            lspconfig[name]
            and lspconfig[name].document_config
            and lspconfig[name].document_config.default_config
          then
            default_cmd = lspconfig[name].document_config.default_config.cmd
          end
          local check_cmd = cmd or default_cmd
          available = is_cmd_available(check_cmd)
        end

        if available and lspconfig[name] then
          lspconfig[name].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = (function()
              -- Inject interpreter/venv hints per server
              local merged = vim.deepcopy(settings)
              if name == "pyright" or name == "basedpyright" then
                merged.python = merged.python or {}
                merged.python.venvPath = PYENV.venv_dirname or merged.python.venvPath
                merged.python.venv = PYENV.venv_name or merged.python.venv
                -- Use modern interpreter setting for Pyright/BasedPyright
                merged.python.defaultInterpreterPath = PYENV.python_bin or merged.python.defaultInterpreterPath
              elseif name == "pylsp" then
                merged.pylsp = merged.pylsp or {}
                merged.pylsp.plugins = merged.pylsp.plugins or {}
                merged.pylsp.plugins.jedi = merged.pylsp.plugins.jedi or {}
                merged.pylsp.plugins.jedi.environment = PYENV.python_bin or merged.pylsp.plugins.jedi.environment
              end
              return merged
            end)(),
            -- cmd = cmd, -- keep default if not provided
            root_dir = lspconfig.util.root_pattern(
              ".git",
              "pyproject.toml",
              "setup.py",
              "setup.cfg",
              "requirements.txt"
            ),
          })
          vim.notify("LSP: started " .. name .. " for Python", vim.log.levels.INFO)
          return true
        end
      end
      return false
    end

    local started = setup_first_available({
      {
        name = "basedpyright",
        settings = {
          basedpyright = {
            disableOrganizeImports = false,
            analysis = {
              typeCheckingMode = "basic",
              autoImportCompletions = true,
              diagnosticMode = "workspace",
            },
          },
        },
      },
      {
        name = "pyright",
        settings = {
          pyright = { disableOrganizeImports = false },
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoImportCompletions = true,
              diagnosticMode = "workspace",
            },
          },
        },
      },
      {
        name = "pylsp",
        settings = {
          pylsp = {
            plugins = {
              pycodestyle = { enabled = true, maxLineLength = 100 },
              pyflakes = { enabled = true },
              mccabe = { enabled = false },
              pylsp_mypy = { enabled = false },
              rope = { enabled = false },
              yapf = { enabled = false },
              autopep8 = { enabled = false },
              black = { enabled = true },
              isort = { enabled = true },
            },
          },
        },
      },
    })

    if not started then
      vim.notify("No Python LSP could be started. Install one of: basedpyright, pyright, pylsp", vim.log.levels.WARN)
    end
  end,
}
