local api = require( "softvisio/api" )
local utils = require( "softvisio/utils" )

local function execute ( input )

    if not input.fargs[ 1 ] then
        utils.echoe( "Command is required" )

    -- lint
    elseif input.fargs[ 1 ] == "lint" then
        api.lint( 0, input.fargs[ 2 ] )

    -- browser
    elseif input.fargs[ 1 ] == "browser" then
        api.browser( 0 )

    -- invalid command
    else
        utils.echoe( "Command is not valid: " .. input.fargs[ 1 ] )
    end
end

local function complete ( ... )
end

local M = {
    setup = function ()
        vim.api.nvim_create_user_command( "S", execute, {
            nargs = "*",
            complete = complete,
            desc = "Softvisio LSP",
        } )
    end,
}

return M
