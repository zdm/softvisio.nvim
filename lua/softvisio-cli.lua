local M = {}

local utils = require( "utils" )

local TYPES = {
    javascript = "text/javascript",
    typescript = "application/x-typescript",
    json = "application/json",
    sh = "application/x-sh",
    ant = "text/xml",
}

local EOL = {
    unix = "\n",
    dos = "\r\n",
    mac = "\r",
}

local client

-- private
local function get_client ()
    if not client then
        client = vim.lsp.start( {
            name = "softvisio-cli",
            cmd = vim.lsp.rpc.connect( "127.0.0.1", 55557 ),
        } )
    end

    return client
end

local function echo ( message, hl )
    -- vim.cmd( "silent! redraw" )

    if hl then
        vim.cmd.echohl( hl )
    end

    vim.cmd.echo( '"' .. message .. '"' )

    if hl then
        vim.cmd.echohl( "None" )
    end
end

-- public
M.setup = function ( options )
end

M.attach = function ( bufnr )
    local client = get_client()

    return vim.lsp.buf_attach_client( bufnr, client )
end

-- client:supports_method( "textDocument/formatting" )
-- XXX
M.lint = function ( bufnr )
    local winid = vim.fn.bufwinid( bufnr )
    local action = "lint"
    local eol = EOL[ vim.bo[ bufnr ].fileformat ]
    local buffer = vim.fn.join( vim.fn.getline( 1, "$" ), eol )

    -- buffer is empty
    if buffer == "" then
        echo( "Buffer is empty", "Comment" )

        return
    end

    -- XXX
    -- insert final newline
    -- if !exists( "b:editorconfig" ) || type( b:editorconfig ) != v:t_dict || b:editorconfig.insert_final_newline == "true"
    buffer = buffer .. eol

    echo( action .. ":  run source filter..." )

    local client = get_client()

    local res = vim.lsp.buf_request_sync( bufnr, "softvisio-cli/lint", {
        action = action,
        cwd = vim.fn.getcwd(),
        path = vim.fn.expand( "%:p" ),
        type = TYPES[ vim.bo[ bufnr ].filetype ],
        buffer = buffer,
    } )

    if not res then
        return
    end

    res = res[ 1 ].result

    -- buffer was changed
    if res.meta.isModified then

        -- XXX
        res.data = vim.fn.substitute( res.data, "\r\n\\?", "\n", "g" )

        local cursor_pos = vim.fn.getpos( "." )
        local syntax = vim.bo[ bufnr ].syntax == "on" and true or false
        local foldmethod = vim.wo[ winid ].foldmethod

        if syntax then
            vim.bo[ bufnr ].syntax = "off"
        end

        vim.wo[ winid ].foldmethod = "manual"

        vim.cmd( "%delete" )
        vim.api.nvim_buf_set_lines( bufnr, 0, 0, false, { res.data } )
        vim.cmd( "1delete 1" )

        -- refresh treesitter, if used
        if utils.hasTreesitter() then
            utils.parseTreesitter()
        end

    end

    -- update diagnostics
    -- utils.setDiagnostic( 0, res.meta.diagnostic )

    --  parsing error
    if res.meta.parsingError then
        echo( action .. ": " .. res.status_text, "ErrorMsg" )

        require( "trouble" ).open( "diagnostics" )
        require( "trouble" ).focus()

    -- errors
    elseif res.meta.hasErrors then
        echo( action .. ": " .. res.status_text, "ErrorMsg" )

    -- warnings
    elseif res.meta.hasWarnings then
        echo( action .. ": " .. res.status_text, "WarningMsg" )

    -- ok
    else
        echo( action .. ": " .. res.status_text, "Comment" )
    end

end

vim.keymap.set( { "n", "i" }, "<Leader>z", function ()
    local bufnr = vim.api.nvim_get_current_buf()

    M.attach( bufnr )

    M.lint( bufnr )
end )

return M;
