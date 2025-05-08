local OPTIONS = {
    hostname = "127.0.0.1",
    port = 55556,
    auto_attach = false,
    timeout = 60000,
    ignored_filetypes = {},
    use_notify = false,
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

        -- prepare ignored_filetypes
        local ignored_filetypes = {};

        for _, value in pairs( OPTIONS.ignored_filetypes ) do
            ignored_filetypes[ value ] = true
        end

        OPTIONS.ignored_filetypes = ignored_filetypes
    end,
}

return setmetatable( M, {
    __index = function( _, key )
        return OPTIONS[ key ]
    end,
} )
