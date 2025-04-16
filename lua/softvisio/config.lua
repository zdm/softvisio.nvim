local OPTIONS = {
    hostname = "127.0.0.1",
    port = 55556,
    auto_attach = false,
    timeout = 60000,
}
local M

M = {
    setup = function ( options )
        if not options then
            options = {}
        end

        for key, value in pairs( OPTIONS ) do
            if options[ key ] then
                OPTIONS[ key ] = options[ key ]
            end
        end
    end,
}

return setmetatable( M, {
    __index = function( _, key )
        return OPTIONS[ key ]
    end,
} )
