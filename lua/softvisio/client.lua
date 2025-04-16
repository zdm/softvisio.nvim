local config = require( "softvisio/config" )
local utils = require( "softvisio/utils" )
local server
local client
local M


local function test_rpc ()
    local channel

    pcall( function ()
        channel = vim.fn.sockconnect( "tcp", config.hostname .. ":" .. config.port )
    end )

    if not channel then
        return false
    else
        vim.fn.chanclose( channel )

        return true
    end
end

local function spawn_Server ()
    if not server then
        local cmd = vim.fn.has( "win32" ) == 1 and "softvisio-cli.cmd" or "softvisio-cli"

        server = vim.fn.jobstart( cmd .. " lsp start", {
            detach = false,
        } )
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
            if test_rpc() then
                client = vim.lsp.get_client_by_id( vim.lsp.start( {
                    name = "softvisio",
                    cmd = vim.lsp.rpc.connect( config.hostname, config.port ),
                    on_error = function ( code, e )
                        if e == "ECONNRESET" then
                            vim.lsp.stop_client( client.id, true )

                            client = nil
                        end
                    end
                } ) )
            else
                spawn_Server()

                utils.echoe( "Unable to connect to the LSP RPC server" )
            end
        end

        return client
    end,

    attach = function ( bufnr )
        vim.lsp.buf_attach_client( bufnr, M.get().id )
    end,
}

return M
