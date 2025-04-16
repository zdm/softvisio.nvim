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

        if options.hostname then
            OPTIONS.hostname = options.hostname
        end

        if options.port then
            OPTIONS.port = options.port
        end

        if options.auto_attach then
            OPTIONS.auto_attach = options.auto_attach
        end

        if options.timeout then
            OPTIONS.timeout = options.timeout
        end
    end,
}

return setmetatable( M, {
    __index = function( _, key )
        return OPTIONS[ key ]
    end,
} )
