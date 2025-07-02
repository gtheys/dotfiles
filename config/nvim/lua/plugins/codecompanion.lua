return {
  "olimorris/codecompanion.nvim",
  event = "VeryLazy",
  dependencies = {
    "ravitemer/mcphub.nvim",
    { "nvim-lua/plenary.nvim", branch = "master" },
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "j-hui/fidget.nvim", -- Add this line for fidget.nvim
    "ravitemer/codecompanion-history.nvim",
  },
  opts = {
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
      },
      inline = {
        adapter = {
          name = "openrouter",
          model = "anthropic/claude-3-haiku",
        },
      },
      agent = {
        adapter = {
          name = "openrouter",
          model = "anthropic/claude-sonnet-4",
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
    -- Add the vectorcode configuration
    extensions = {
      history = {
        enabled = true,
        opts = {
          -- Keymap to open history from chat buffer (default: gh)
          keymap = "gh",
          -- Keymap to save the current chat manually (when auto_save is disabled)
          save_chat_keymap = "sc",
          -- Save all chats by default (disable to save only manually using 'sc')
          auto_save = true,
          -- Number of days after which chats are automatically deleted (0 to disable)
          expiration_days = 0,
          -- Picker interface (auto resolved to a valid picker)
          picker = "snacks", --- ("telescope", "snacks", "fzf-lua", or "default")
          -- Customize picker keymaps (optional)
          picker_keymaps = {
            rename = { n = "r", i = "<M-r>" },
            delete = { n = "d", i = "<M-d>" },
            duplicate = { n = "<C-y>", i = "<C-y>" },
          },
          ---Automatically generate titles for new chats
          auto_generate_title = true,
          title_generation_opts = {
            ---Adapter for generating titles (defaults to current chat adapter)
            adapter = nil, -- "copilot"
            ---Model for generating titles (defaults to current chat model)
            model = nil, -- "gpt-4o"
            ---Number of user prompts after which to refresh the title (0 to disable)
            refresh_every_n_prompts = 0, -- e.g., 3 to refresh after every 3rd user prompt
            ---Maximum number of times to refresh the title (default: 3)
            max_refreshes = 3,
          },
          ---On exiting and entering neovim, loads the last chat on opening chat
          continue_last_chat = false,
          ---When chat is cleared with `gx` delete the chat from history
          delete_on_clearing_chat = false,
          ---Directory path to save the chats
          dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
          ---Enable detailed logging for history extension
          enable_logging = false,
          ---Optional filter function to control which chats are shown when browsing
          chat_filter = nil, -- function(chat_data) return boolean end
        },
      },
      vectorcode = {
        ---@type VectorCode.CodeCompanion.ExtensionOpts
        opts = {
          tool_group = {
            enabled = true,
            collapse = true,
            -- tools in this array will be included to the `vectorcode_toolbox` tool group
            extras = {},
          },
          tool_opts = {
            ---@type VectorCode.CodeCompanion.LsToolOpts
            ls = {},
            ---@type VectorCode.CodeCompanion.QueryToolOpts
            query = {},
            ---@type VectorCode.CodeCompanion.VectoriseToolOpts
            vectorise = {},
          },
        },
      },
    },
  },
  keys = {
    { "<leader>az", "<cmd>CodeCompanionChat Toggle<cr>", desc = "CodeCompanion Chat Toggle", mode = { "n", "v" } },
    { "<leader>ac", "<cmd>CodeCompanionChat Add<cr>", desc = "CodeCompanion Add selection", mode = "v" },
    { "<leader>ai", "<cmd>CodeCompanion<cr>", desc = "CodeCompanion Inline", mode = "n" },
    { "<leader>ae", "<cmd>CodeCompanion<cr>", desc = "CodeCompanion Edit selection", mode = "v" },
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion Actions", mode = { "n", "v" } },
    -- ... your other keys
  },
  config = function(_, opts)
    opts.strategies.chat.tools = {
      ["mcp"] = {
        callback = require("mcphub.extensions.codecompanion"),
        description = "Call tools and resources from MCP Servers",
        opts = {
          show_result_in_chat = true,
          make_vars = true,
          make_slash_commands = true,
        },
      },
    }

    require("codecompanion").setup(opts)

    vim.cmd([[cabbrev cc CodeCompanion]])
    vim.cmd([[cabbrev cca CodeCompanionChat]])
    vim.cmd([[cabbrev cci CodeCompanionInline]])
    vim.notify("CodeCompanion configured with OpenRouter and MCPHub.", vim.log.levels.INFO)

    require("fidget").setup({}) -- Setup fidget.nvim here
  end,
}
