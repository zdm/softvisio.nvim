local config = require( "softvisio/config" )
local server
local client
local M

-- XXX
local function spawnLspServer ()
    if not server then

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

        server = {
            handle = handle,
            pid = pid,
        }
    end
end

M = {
    setup = function ()
        if config.auto_attach then
            vim.api.nvim_create_autocmd( { "BufFilePost", "BufRead", "BufNewFile", "BufWritePost" }, {
                -- group = "softvisio",
                desc = "softvisio: attach",
                callback = function ( args )
                    local bufnr = args.buf

                    M.attach( bufnr )
                end,
            } )

        end
    end,

    get = function ()
        if not client then
            client = vim.lsp.get_client_by_id( vim.lsp.start( {
                name = "softvisio",
                cmd = vim.lsp.rpc.connect( config.hostname, config.port ),
                on_error = function ( code, err )
                    if err == "ECONNRESET" then
                        vim.lsp.stop_client( client.id, true )

                        client = nil
                    end
                end
            } ) )
        end

        return client
    end,

    attach = function ( bufnr )
        vim.lsp.buf_attach_client( bufnr, M.get().id )
    end,
}

return M
