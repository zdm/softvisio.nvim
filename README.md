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
        cmd = "S",
        keys = {
            {
                "<Leader>sd",
                "<CMD>S lint format<CR>",
                mode = { "n", "i", "v", "s" },
                desc = "Lint buffer using default rules",
            },
            {
                "<Leader>sf",
                "<CMD>S lint lint<CR>",
                mode = { "n", "i", "v", "s" },
                desc = "Lint buffer",
            },
            {
                "<Leader>sc",
                "<CMD>S lint compress<CR>",
                mode = { "n", "i", "v", "s" },
                desc = "Compress buffer",
            },
            {
                "<Leader>so",
                "<CMD>S lint obfuscate<CR>",
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
                ignored_filetypes = {
                    "DiffviewFileHistory",
                    "DiffviewFiles",
                    "gitgraph",
                    "help",
                    "trouble",
                },
            } )
        end
    }
}
```
