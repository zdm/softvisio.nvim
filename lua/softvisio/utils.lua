local EOL = {
    unix = "\n",
    dos = "\r\n",
    mac = "\r",
}
local error_level_hl = {
    info = "Comment",
    error = "ErrorMsg",
    warning = "WarningMsg",
}
local M

M = {
    has_treesitter = function ( bufnr )
        if not bufnr then
            bufnr = vim.api.nvim_get_current_buf()
        end

        local highlighter = require( "vim.treesitter.highlighter" )

        if highlighter.active[ bufnr ] then
            return true
        else
            return false
        end
    end,

    parse_treesitter = function ( bufnr, range )
        local parser = vim.treesitter.get_parser( bufnr )

        -- NOTE: https://neovim.io/doc/user/treesitter.html#LanguageTree%3Aparse()
        parser:parse( range )
    end,

    echo = function ( message, level )
        vim.cmd( "redraw" )

        local hl = error_level_hl[ level ]

        if hl then
            vim.cmd.echohl( hl )
        end

        vim.cmd.echo( '"' .. message .. '"' )

        if hl then
            vim.cmd.echohl( "None" )
        end
    end,

    echoc = function ( message )
        M.echo( message, "info" )
    end,

    echoe = function ( message )
        M.echo( message, "error" )
    end,

    echow = function ( message )
        M.echo( message, "warning" )
    end,

    get_buffer = function ( bufnr )
        local eol = EOL[ vim.bo[ bufnr ].fileformat ]
        local buffer = vim.fn.join( vim.fn.getline( 1, "$" ), eol )

        if buffer ~= "" then

            -- add final newline
            if not vim.b[ bufnr ].editorconfig or not vim.b[ bufnr ].editorconfig.insert_final_newline or vim.b[ bufnr ].editorconfig.insert_final_newline == "true" then
                buffer = buffer .. eol
            end
        end

        return buffer
    end,

    set_diagnostic = function ( bufnr, diagnostic )
        local namespace = vim.api.nvim_create_namespace( "softvisio" )

        -- vim.diagnostic.config( options, namespace )

        if diagnostic == nil then
            vim.diagnostic.reset( namespace, bufnr )
        else
            for index, value in ipairs( diagnostic ) do
                value.severity = vim.diagnostic.severity[ value.severity ]
            end

            vim.diagnostic.set( namespace, bufnr, diagnostic )
        end
    end,

    open_diagnostics = function ()
        if vim.fn.exists( ":Telescope" ) > 0 then
            local namespace = vim.api.nvim_create_namespace( "softvisio" )

            vim.cmd( "Telescope diagnostics bufnr=0 namespace=" .. namespace );
        end
    end,
}

return M
