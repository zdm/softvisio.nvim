local M = {}

local HOSTNAME = "127.0.0.1"
local PORT = 55557

local utils = require( "softvisio/utils" )

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

local LSP_SERVER
local client

-- private
local function spawn_lsp_server ()
    if not LSP_SERVER then

        -- https://neovim.io/doc/user/lua.html#vim.system()
        -- https://neovim.io/doc/user/luvref.html#uv.spawn()
        -- https://neovim.io/doc/user/luvref.html#uv.tcp_connect()
        local handle, pid = vim.uv.spawn(
            vim.fn.has( "win32" ) == 1 and "softvisio-cli.cmd" or "softvisio-cli",
            {
                args = { "lsp", "start" },
                stdio = nil,
                detached = false,
                hide = true,
            },
            function ( code, signal )
                vim.print( "---", code, signal )
                LSP_SERVER = nil
            end
        )

        LSP_SERVER = {
            handle = handle,
            pid = pid,
        }
    end
end

local function get_client ()
    if not client then
        client = vim.lsp.start( {
            name = "softvisio",
            cmd = vim.lsp.rpc.connect( HOSTNAME, PORT ),
        } )
    end

    return client
end

local function do_request ( bufnr, method, params )
    local client = get_client()

    local res = vim.lsp.buf_request_sync( bufnr, method, params )

    if not res then
        return
    else
        return res[ 1 ].result
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

    -- XXX
    local action = "lint"

    local winid = vim.fn.bufwinid( bufnr )
    local eol = EOL[ vim.bo[ bufnr ].fileformat ]
    local buffer = vim.fn.join( vim.fn.getline( 1, "$" ), eol )

    -- buffer is empty
    if buffer == "" then
        utils.echo( "Buffer is empty", "Comment" )

        return
    end

    -- add final newline
    if not vim.b[ bufnr ].editorconfig or vim.b[ bufnr ].editorconfig.insert_final_newline == "true" then
        buffer = buffer .. eol
    end

    utils.echo( action .. ":  run source filter..." )

    local res = do_request( bufnr, "softvisio/lint", {
        action = action,
        cwd = vim.fn.getcwd(),
        path = vim.fn.expand( "%:p" ),
        type = TYPES[ vim.bo[ bufnr ].filetype ],
        buffer = buffer,
    } )

    if not res then
        utils.echoe( "Not connected to the LSP server" )

        return
    end

    -- buffer was changed
    if res.meta.isModified then
        local lines = vim.fn.split( res.data, "\r\n\\|\r\\|\n" )
        local cursor_pos = vim.fn.getpos( "." )
        local syntax = vim.bo[ bufnr ].syntax == "on" and true or false
        local foldmethod = vim.wo[ winid ].foldmethod

        if syntax then
            vim.bo[ bufnr ].syntax = "off"
        end

        vim.wo[ winid ].foldmethod = "manual"

        vim.api.nvim_buf_set_lines( bufnr, 0, -1, false, {} )
        vim.api.nvim_buf_set_lines( bufnr, 0, #lines, false, lines )

        -- refresh treesitter, if used
        if utils.hasTreesitter() then
            utils.parseTreesitter()
        end

        -- refresh syntax, if used
        if syntax then
            vim.bo[ bufnr ].syntax = "on"
            vim.cmd( "syn sync fromstart" )
        end

        -- restore cursor position
        vim.fn.setpos( ".", cursor_pos )

        -- open fold under the cursor
        vim.wo[ winid ].foldmethod = foldmethod
        vim.cmd.normal( "zM" )
        vim.cmd.normal( "zv" )

        -- center cursor on the screen
        vim.cmd.normal( "zz" )
    end

    -- update diagnostics
    utils.setDiagnostic( 0, res.meta.diagnostic )

    --  parsing error
    if res.meta.parsingError then
        utils.echoe( action .. ": " .. res.status_text )

        require( "trouble" ).open( "diagnostics" )
        require( "trouble" ).focus()

    -- errors
    elseif res.meta.hasErrors then
        utils.echoe( action .. ": " .. res.status_text )

    -- warnings
    elseif res.meta.hasWarnings then
        utils.echow( action .. ": " .. res.status_text )

    -- ok
    else
        utils.echoc( action .. ": " .. res.status_text )
    end

end

vim.keymap.set( { "n", "i" }, "<Leader>z", function ()
    local bufnr = vim.api.nvim_get_current_buf()

    -- spawn_lsp_server()

    M.attach( bufnr )

    M.lint( bufnr )
end )

return M;
