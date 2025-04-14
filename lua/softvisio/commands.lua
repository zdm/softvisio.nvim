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

    -- lint
    if ( input.fargs[ 1 ] == "lint" ) then
        api.lint( 0, input.fargs[ 2 ] )

    -- browser
    elseif ( input.fargs[ 1 ] == "browser" ) then
        api.browser( 0 )

    -- invalid command
    else
        echoe( "Command is not valid" )
    end
end

function M.complete ( ... )
end

return M
