local OPTIONS = {
    hostname = "127.0.0.1",
    port = 55556,
    auto_attach = false,
    timeout = 60000,
}
local M

M = {
    setup = function ( options )
    end,
}

return setmetatable( M, {
    __index = function( _, key )
        return OPTIONS[ key ]
    end,
} )
