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
    get = function ()
        if not client then
            client = vim.lsp.start( {
                name = "softvisio",
                cmd = vim.lsp.rpc.connect( config.hostname, config.port ),
            } )
        end

        return client
    end
}

return M
