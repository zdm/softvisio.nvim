local M = {}

M.hasTreesitter = function ( bufnr )
    if not bufnr then
        bufnr = vim.api.nvim_get_current_buf()
    end

    local highlighter = require( "vim.treesitter.highlighter" )

    if highlighter.active[ bufnr ] then
        return true
    else
        return false
    end
end

M.parseTreesitter = function ( bufnr, range )
    local parser = vim.treesitter.get_parser( bufnr )

    -- XXX https://neovim.io/doc/user/treesitter.html#LanguageTree%3Aparse()
    parser:parse( range )
end

M.setDiagnostic = function ( bufnr, diagnostic )
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
end

M.echo = function ( message, hl )
    vim.cmd( "silent! redraw" )

    if hl then
        vim.cmd.echohl( hl )
    end

    vim.cmd.echo( '"' .. message .. '"' )

    if hl then
        vim.cmd.echohl( "None" )
    end
end

M.echoc = function ( message )
    M.echo( message, "Comment" )
end

M.echoe = function ( message )
    M.echo( message, "ErrorMsg" )
end

M.echow = function ( message )
    M.echo( message, "WarningMsg" )
end

return M
