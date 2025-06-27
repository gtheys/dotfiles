return {
  "olimorris/codecompanion.nvim",
  event = "VeryLazy",
  dependencies = {
    "ravitemer/mcphub.nvim",
    { "nvim-lua/plenary.nvim", branch = "master" },
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
  },
  opts = {
    -- We will keep the 'opts' table for simple values, but remove the 'tools'
    -- table from here, as it contains a 'require' call.
    log_level = "INFO",
    adapters = {
      openrouter = function()
        return require("codecompanion.adapters").extend("openai_compatible", {
          env = {
            api_key = os.getenv("OPENROUTER_API_KEY"),
            url = "https://openrouter.ai/api/v1",
            chat_url = "/chat/completions",
          },
          schema = {
            model = {
              default = "anthropic/claude-3-opus",
              choices = {
                "anthropic/claude-3-opus",
                "anthropic/claude-3.5-sonnet",
                "openai/gpt-4o",
                "openai/gpt-4o-mini",
                "google/gemini-2.5-pro",
                "anthropic/claude-3-haiku",
                "meta-llama/llama-3.1-8b-instruct:free",
                "mistralai/mistral-nemo:free",
              },
            },
          },
        })
      end,
    },
    strategies = {
      chat = {
        adapter = {
          name = "openrouter",
          model = "openai/gpt-4o",
        },
        -- The 'tools' table is now removed from here and will be added
        -- inside the 'config' function below.
      },
      inline = {
        adapter = {
          name = "openrouter",
          model = "anthropic/claude-3-haiku", -- Example model
        },
      },
      agent = {
        adapter = {
          name = "openrouter",
          model = "google/gemini-2.5-pro",
        },
      },
    },
    display = {
      chat = {
        window = {
          layout = "vertical",
          width = 0.5,
          height = 0.9,
        },
      },
    },
  },
  keys = {
    { "<leader>az", "<cmd>CodeCompanionChat Toggle<cr>", desc = "CodeCompanion Chat Toggle", mode = { "n", "v" } },
    -- ... your other keys
  },
  -- V V V V  THE MAIN FIX IS IN THIS FUNCTION  V V V V
  config = function(_, opts)
    -- This 'config' function runs AFTER dependencies like 'mcphub.nvim' are loaded.
    -- This is the safe place to 'require' its modules.

    -- 1. Lazily define the tools table and add it to the opts.
    opts.strategies.chat.tools = {
      ["mcp"] = {
        -- 2. This 'require' is now safe and will not error.
        callback = require("mcphub.extensions.codecompanion"),
        description = "Call tools and resources from MCP Servers",
        opts = {
          show_result_in_chat = true,
          make_vars = true,
          make_slash_commands = true,
        },
      },
    }

    -- 3. Now, call the setup function with the fully constructed 'opts' table.
    require("codecompanion").setup(opts)

    -- The rest of your original config function is fine.
    vim.cmd([[cabbrev cc CodeCompanion]])
    vim.cmd([[cabbrev cca CodeCompanionChat]])
    vim.cmd([[cabbrev cci CodeCompanionInline]])
    vim.notify("CodeCompanion configured with OpenRouter and MCPHub.", vim.log.levels.INFO)
  end,
}
