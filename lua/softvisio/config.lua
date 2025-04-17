local OPTIONS = {
    hostname = "127.0.0.1",
    port = 55556,
    auto_attach = false,
    timeout = 60000,
    disabled_filetypes = {},
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

        -- prepare disabled_filetypes
        local disabled_filetypes = {};

        for _, value in pairs( OPTIONS.disabled_filetypes ) do
            disabled_filetypes[ value ] = true
        end

        OPTIONS.disabled_filetypes = disabled_filetypes
    end,
}

return setmetatable( M, {
    __index = function( _, key )
        return OPTIONS[ key ]
    end,
} )
