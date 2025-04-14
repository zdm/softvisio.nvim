local EOL = {
    unix = "\n",
    dos = "\r\n",
    mac = "\r",
}

local M = {
    hasTreesitter = function ( bufnr )
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

    parseTreesitter = function ( bufnr, range )
        local parser = vim.treesitter.get_parser( bufnr )

        -- XXX https://neovim.io/doc/user/treesitter.html#LanguageTree%3Aparse()
        parser:parse( range )
    end,

    setDiagnostic = function ( bufnr, diagnostic )
        local namespace = vim.api.nvim_create_namespace( "softvisio" )

        -- vim.diagnostic.config( options, namespace )

        if diagnostic == nil then
            vim.diagnostic.reset( namespace, bufnr )

            require( "trouble" ).close( "diagnostics" );
        else
            for index, value in ipairs( diagnostic ) do
                value.severity = vim.diagnostic.severity[ value.severity ]
            end

            vim.diagnostic.set( namespace, bufnr, diagnostic )
        end
    end,

    echo = function ( message, hl )
        vim.cmd( "silent! redraw" )

        if hl then
            vim.cmd.echohl( hl )
        end

        vim.cmd.echo( '"' .. message .. '"' )

        if hl then
            vim.cmd.echohl( "None" )
        end
    end,

    echoc = function ( message )
        M.echo( message, "Comment" )
    end,

    echoe = function ( message )
        M.echo( message, "ErrorMsg" )
    end,

    echow = function ( message )
        M.echo( message, "WarningMsg" )
    end,

    get_buffer = function ( bufnr )
        local eol = EOL[ vim.bo[ bufnr ].fileformat ]
        local buffer = vim.fn.join( vim.fn.getline( 1, "$" ), eol )

        if buffer ~= "" then

            -- add final newline
            if not vim.b[ bufnr ].editorconfig or vim.b[ bufnr ].editorconfig.insert_final_newline == "true" then
                buffer = buffer .. eol
            end
        end

        return buffer
    end,
}

return M
