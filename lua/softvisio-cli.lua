local M = {}

local client

-- private
local function get_client ()
    if not client then
        client = vim.lsp.start( {
            name = "softvisio",
            cmd = vim.lsp.rpc.connect( "127.0.0.1", 55557 ),
        } )
    end

    return client
end

-- public
M.setup = function ( options )
    vim.print( options )
end

M.attach = function ( bufnr )
    local client = get_client()

    return vim.lsp.buf_attach_client( bufnr, client )
end

-- client:supports_method( "textDocument/formatting" )
M.lint = function ( bufnr )
    local client = get_client()

    return vim.lsp.buf.format( {
        bufnr = bufnr,
        id = client,
        timeout_ms = 1000,
        range = nil,
    } )
end

vim.keymap.set( { "n", "i" }, "<Leader>z", function ()
vim.api.nvim_get_current_buf()
    local bufnr = vim.api.nvim_get_current_buf()

    M.attach( bufnr )

    M.lint( bufnr )
end )

return M;
