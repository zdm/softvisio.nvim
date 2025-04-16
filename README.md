# `softvisio.nvim`

`@softvisio/cli` LSP server integration for `Neovim`.

## Requirements

1. `@softvisio/cli` `npm` package, installed globally:

```sh
npm install --global @softvisio/cli
```

## Setup

```lua
return {
    {
        "zdm/softvisio.nvim",
        dependencies = {
            "folke/trouble.nvim",
        },
        lazy = false,
        cmd = "S",
        keys = {
            {
                "<leader>sd",
                "<esc>:S lint format<cr>",
                mode = { "n", "i", "v", "s" },
                desc = "Lint buffer using default rules",
            },
            {
                "<leader>sf",
                "<esc>:S lint lint<cr>",
                mode = { "n", "i", "v", "s" },
                desc = "Lint buffer",
            },
            {
                "<leader>sc",
                "<esc>:S lint compress<cr>",
                mode = { "n", "i", "v", "s" },
                desc = "Compress buffer",
            },
            {
                "<leader>so",
                "<esc>:S lint obfuscate<cr>",
                mode = { "n", "i", "v", "s" },
                desc = "Obfuscate buffer",
            },
        },
        config = function ()
            require( "softvisio" ).setup( {
                hostname = "127.0.0.1",
                port = 55556,
                auto_attach = false,
                timeout = 60000,
            } )
        end
    }
}
```
