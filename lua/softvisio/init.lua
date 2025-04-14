local M

M = {
    setup = function ( options )
        require( "softvisio/config" ).setup( options )

        require( "softvisio/commands" ).setup( options )
    end,
}

return setmetatable( M, {
    __index = function( _, k )
        return require( "softvisio.api" )[ k ]
    end,
} )
