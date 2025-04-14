local api = require( "softvisio/api" )
local utils = require( "softvisio/utils" )
local M = {}

function M.setup ()
    vim.api.nvim_create_user_command( "S", M.execute, {
        nargs = "*",
        complete = M.complete,
        desc = "Softvisio LSP",
    } )
end

function M.execute ( input )

    if not input.fargs[ 1 ] then
        utils.echoe( "Command is required" )

    -- lint
    elseif ( input.fargs[ 1 ] == "lint" ) then
        api.lint( 0, input.fargs[ 2 ] )

    -- browser
    elseif ( input.fargs[ 1 ] == "browser" ) then
        api.browser( 0 )

    -- invalid command
    else
        utils.echoe( "Command is not valid: " .. input.fargs[ 1 ] )
    end
end

function M.complete ( ... )
end

return M
