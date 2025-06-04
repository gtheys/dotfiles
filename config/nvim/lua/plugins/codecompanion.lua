return {
  "olimorris/codecompanion.nvim",
  -- Using 'event = "VeryLazy"' is generally preferred for AI plugins
  -- as it loads them early, making them available when you need them.
  -- The 'cmd' table becomes redundant if 'event = "VeryLazy"' is active.
  event = "VeryLazy",
  dependencies = {
    -- Essential dependency for CodeCompanion. Pin to master if you pin other plugins to releases.
    { "nvim-lua/plenary.nvim", branch = "master" },
    "nvim-treesitter/nvim-treesitter", -- Required for parsing and other features
    "stevearc/dressing.nvim", -- LazyVim includes this

    {
      "saghen/blink.cmp",
      opts = {
        sources = {
          -- Configure CodeCompanion as a default completion source for blink.cmp.
          -- This enables slash commands like /file.
          default = { "codecompanion" },
          providers = {
            codecompanion = {
              name = "CodeCompanion",
              module = "codecompanion.providers.completion.blink",
              enabled = true,
            },
          },
        },
      },
    },
  },
  opts = {
    -- **OpenRouter Adapter Configuration**
    adapters = {
      openrouter = function()
        return require("codecompanion.adapters").extend("openai_compatible", {
          env = {
            -- Explicitly fetch the API key from the environment variable.
            -- This is safer and clearer than just using the string literal.
            api_key = os.getenv("OPENROUTER_API_KEY"),
            url = "https://openrouter.ai/api/v1",
            chat_url = "/chat/completions",
          },
          schema = {
            model = {
              default = "anthropic/claude-opus-4", -- Updated to actual available model
              choices = {
                -- 🔥 Best Coding Models (Available on OpenRouter)
                "anthropic/claude-sonnet-4",
                "anthropic/claude-3.7-sonnet",
                "openai/gpt-4o",
                "openai/gpt-4o-mini",
                "deepseek/deepseek-r1-0528",
                "google/gemini-2.5-pro-preview",
                -- ⚡ Fast & Efficient
                "anthropic/claude-3.5-haiku-20241022",
                -- 🆓 Free Options
                "meta-llama/llama-3.1-8b-instruct:free",
                "qwen/qwen-2-7b-instruct:free",
                -- 🔧 Specialized
                "qwen/qwen-2.5-coder-32b-instruct",
              },
            },
          },
        })
      end,
    },
    -- Set this adapter as the default for chat, inline, and agent strategies
    strategies = {
      chat = {
        adapter = {
          name = "openrouter",
          model = "openai/gpt-4o", -- Using GPT-4o for chat
        },
      },
      inline = {
        adapter = {
          name = "openrouter",
          model = "qwen/qwen-2.5-coder-32b-instruct", -- Using Qwen Coder for inline transformations
        },
      },
      agent = {
        adapter = {
          name = "openrouter",
          model = "google/gemini-2.5-pro-preview", -- Using Gemini Pro Preview for agentic actions
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
    -- Corrected placement: log_level should be directly under the main 'opts' table
    log_level = "INFO", -- Optional: Enable debug logging for troubleshooting
  },
  keys = {
    -- Your custom keymaps - Fixed with proper command syntax
    { "<leader>az", "<cmd>CodeCompanionChat Toggle<cr>", desc = "CodeCompanion Chat Toggle", mode = { "n", "v" } },
    { "<leader>ac", "<cmd>CodeCompanionChat Add<cr>", desc = "CodeCompanion Add selection", mode = "v" },
    { "<leader>ai", "<cmd>CodeCompanion<cr>", desc = "CodeCompanion Inline", mode = "n" },
    { "<leader>ae", "<cmd>CodeCompanion<cr>", desc = "CodeCompanion Edit selection", mode = "v" },
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion Actions", mode = { "n", "v" } },
    {
      "<leader>am",
      function()
        local models = {
          -- 🔥 Best Coding Models (Available on OpenRouter)
          "anthropic/claude-sonnet-4",
          "anthropic/claude-3.7-sonnet",
          "openai/gpt-4o",
          "openai/gpt-4o-mini",
          "deepseek/deepseek-r1-0528",
          "google/gemini-2.5-pro-preview",
          -- ⚡ Fast & Efficient
          "anthropic/claude-3.5-haiku-20241022",
          -- 🆓 Free Options
          "meta-llama/llama-3.1-8b-instruct:free",
          "qwen/qwen-2-7b-instruct:free",
          -- 🔧 Specialized
          "qwen/qwen-2.5-coder-32b-instruct",
        }
        vim.ui.select(models, {
          prompt = "Select OpenRouter Model:",
          format_item = function(item)
            -- Add emojis and descriptions for better UX
            local descriptions = {
              ["anthropic/claude-sonnet-4"] = "🔥 Claude Sonnet 4 (Most Capable)",
              ["anthropic/claude-3.7-sonnet"] = "🔥 Claude 3.7 Sonnet (Powerful)",
              ["openai/gpt-4o"] = "🔥 GPT-4o (Multimodal)",
              ["openai/gpt-4o-mini"] = "⚡ GPT-4o Mini (Fast)",
              ["deepseek/deepseek-r1-0528"] = "🔥 DeepSeek R1 (Specialized)",
              ["google/gemini-2.5-pro-preview"] = "🔥 Gemini Pro 2.5 (Preview)",
              ["anthropic/claude-3.5-haiku-20241022"] = "⚡ Claude 3.5 Haiku (Fast & Smart)",
              ["meta-llama/llama-3.1-8b-instruct:free"] = "🆓 Llama 3.1 8B (Free)",
              ["qwen/qwen-2-7b-instruct:free"] = "🆓 Qwen 2 7B (Free)",
              ["qwen/qwen-2.5-coder-32b-instruct"] = "🔧 Qwen Coder 32B (Specialized)",
            }
            return descriptions[item] or item
          end,
        }, function(choice)
          if choice then
            vim.notify("Selected model: " .. choice .. "\nUse 'gd' in chat buffer to change it", vim.log.levels.INFO)
          end
        end)
      end,
      desc = "CodeCompanion Select Model",
      mode = "n",
    },
  },
  config = function(_, opts)
    require("codecompanion").setup(opts)
    -- Command abbreviations (LazyVim style)
    vim.cmd([[cabbrev cc CodeCompanion]])
    vim.cmd([[cabbrev cca CodeCompanionChat]])
    vim.cmd([[cabbrev cci CodeCompanionInline]])
    -- Notification
    vim.notify("CodeCompanion configured with OpenRouter adapter.", vim.log.levels.INFO)
  end,
}
