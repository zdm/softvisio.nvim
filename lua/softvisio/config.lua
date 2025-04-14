local OPTIONS = {
    hostname = "127.0.0.1",
    port = 55557,
};

local M = {
    setup = function ( options )
    end,
}

return setmetatable( M, {
    __index = function( _, key )
        return OPTIONS[ key ]
    end,
} )
