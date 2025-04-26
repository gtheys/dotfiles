-- ~/.dotfiles/config/nvim/lua/plugins/codecompanion.lua

return {
  "olimorris/codecompanion.nvim",
  event = "VeryLazy", -- Load lazily when needed
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim", -- Optional but recommended for vim.ui.select
  },
  config = function()
    local cc = require("codecompanion")
    local adapters = require("codecompanion.adapters")

    -- --- Model Configuration ---
    local available_models = {
      "openai/gpt-4o-mini",
      -- Add other OpenRouter models (<provider>/<model>) you want
    }
    local default_model = "anthropic/claude-3.5-sonnet" -- Your desired default
    local current_model_state = { model = default_model }

    -- --- Model Selection Function (for OpenRouter) ---
    local function select_model()
      vim.ui.select(available_models, {
        prompt = "Select OpenRouter Model:", -- Clarified prompt
        default = current_model_state.model,
      }, function(choice)
        if choice then
          current_model_state.model = choice
          -- Update the options for the 'openrouter' adapter dynamically
          local success, err = pcall(cc.set_adapter_options, "openrouter", {
            schema = {
              model = {
                default = current_model_state.model,
              },
            },
          })
          if not success then
            vim.notify("Error setting adapter options: " .. tostring(err), vim.log.levels.ERROR)
          else
            vim.notify("CodeCompanion (OpenRouter) model set to: " .. current_model_state.model)
          end
        end
      end)
    end

    -- --- CodeCompanion Setup ---
    cc.setup({
      -- Define ONLY the adapters you intend to use in this config
      adapters = {
        -- Define the openrouter adapter ONLY
        openrouter = function()
          return adapters.extend("openai_compatible", {
            env = {
              url = "https://openrouter.ai/api",
              -- Reads API key from this environment variable
              api_key = "OPENROUTER_API_KEY",
              chat_url = "/v1/chat/completions",
            },
            schema = {
              model = {
                -- Initial default uses the value set above
                default = current_model_state.model,
              },
              -- options = { temperature = 0.7 }, -- Optional: Add other defaults
            },
          })
        end,
      },

      -- Define strategies and EXPLICITLY assign 'openrouter'
      strategies = {
        chat = {
          adapter = "openrouter", -- Use OpenRouter for chat
        },
        inline = {
          adapter = "openrouter", -- Use OpenRouter for inline actions
        },
        -- Explicitly define other common strategies to use OpenRouter
        agent = {
          adapter = "openrouter",
        },
        edit = {
          adapter = "openrouter",
        },
        fix = {
          adapter = "openrouter",
        },
        -- Add any other strategies you might use and ensure they point here
      },

      -- Global settings
      settings = {
        log_level = "INFO", -- Set to DEBUG for more detailed logs if needed
        chat = {
          window = {
            layout = "vertical",
            width = 0.5,
            height = 0.9,
          },
        },
      },
    })

    -- --- Keymaps ---
    local map = vim.keymap.set
    local opts = { noremap = true, silent = true }

    -- Keymaps using the configured strategies (which now explicitly use openrouter)
    map(
      { "n", "v" },
      "<leader>az",
      "<cmd>CodeCompanionChat Toggle<cr>",
      { desc = "[C]odeCompanion [A]ssistant Toggle", unpack(opts) }
    )
    map("v", "<leader>ac", "<cmd>CodeCompanionChat Add<cr>", { desc = "[C]odeCompanion [A]dd selection", unpack(opts) })
    -- Keymap to select model specifically for the OpenRouter adapter
    map("n", "<leader>am", select_model, { desc = "[C]odeCompanion Select [M]odel (OpenRouter)", unpack(opts) })
    -- Example keymap for inline (will use openrouter)
    map("n", "<leader>ai", "<cmd>CodeCompanionInline<cr>", { desc = "[C]odeCompanion [I]nline", unpack(opts) })
    -- Example keymap for edit (will use openrouter)
    map("v", "<leader>ae", "<cmd>CodeCompanionEdit<cr>", { desc = "[C]odeCompanion [E]dit selection", unpack(opts) })

    -- --- Command Abbreviations ---
    vim.cmd([[cabbrev cc CodeCompanion]])
    vim.cmd([[cabbrev cca CodeCompanionChat]])
    vim.cmd([[cabbrev cci CodeCompanionInline]])

    -- Notify user about setup completion and API key requirement
    vim.notify(
      string.format(
        "CodeCompanion configured for OpenRouter ONLY. Default: %s. Reading API key from OPENROUTER_API_KEY.",
        default_model
      ),
      vim.log.levels.INFO
    )
  end,
}
