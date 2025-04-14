local client = require( "softvisio/client" )
local utils = require( "softvisio/utils" )
local types = {
    javascript = "text/javascript",
    typescript = "application/x-typescript",
    json = "application/json",
    sh = "application/x-sh",
    ant = "text/xml",
}

function attach ( bufnr )
    return vim.lsp.buf_attach_client( bufnr, client.get() )
end

-- XXX attach
local function do_request ( bufnr, method, params )
    attach( bufnr )

    local res = vim.lsp.buf_request_sync( bufnr, method, params )

    if not res then
        return
    else
        return res[ 1 ].result
    end
end

local M = {
    lint = function ( bufnr, action )
        if not bufnr or bufnr == 0 then
            bufnr = vim.api.nvim_get_current_buf()
        end

        if not action then
            action = "lint"
        end

        local winid = vim.fn.bufwinid( bufnr )
        local buffer = utils.get_buffer( bufnr )

        -- buffer is empty
        if buffer == "" then
            utils.echo( "Buffer is empty", "Comment" )

            return
        end

        utils.echo( action .. ":  run source filter..." )

        local res = do_request( bufnr, "softvisio/lint-file", {
            action = action,
            cwd = vim.fn.getcwd(),
            path = vim.fn.expand( "%:p" ),
            type = types[ vim.bo[ bufnr ].filetype ],
            buffer = buffer,
        } )

        if not res then
            utils.echoe( "Not connected to the LSP server" )

            return
        end

        -- buffer was changed
        if res.meta.isModified then
            local lines = vim.fn.split( res.data, "\r\n\\|\r\\|\n" )
            local cursor_pos = vim.fn.getpos( "." )
            local syntax = vim.bo[ bufnr ].syntax == "on" and true or false
            local foldmethod = vim.wo[ winid ].foldmethod

            if syntax then
                vim.bo[ bufnr ].syntax = "off"
            end

            vim.wo[ winid ].foldmethod = "manual"

            vim.api.nvim_buf_set_lines( bufnr, 0, -1, false, {} )
            vim.api.nvim_buf_set_lines( bufnr, 0, #lines, false, lines )

            -- refresh treesitter, if used
            if utils.hasTreesitter() then
                utils.parseTreesitter()
            end

            -- refresh syntax, if used
            if syntax then
                vim.bo[ bufnr ].syntax = "on"
                vim.cmd( "syn sync fromstart" )
            end

            -- restore cursor position
            vim.fn.setpos( ".", cursor_pos )

            -- open fold under the cursor
            vim.wo[ winid ].foldmethod = foldmethod
            vim.cmd.normal( "zM" )
            vim.cmd.normal( "zv" )

            -- center cursor on the screen
            vim.cmd.normal( "zz" )
        end

        -- update diagnostics
        utils.setDiagnostic( 0, res.meta.diagnostic )

        --  parsing error
        if res.meta.parsingError then
            utils.echoe( action .. ": " .. res.status_text )

            require( "trouble" ).open( "diagnostics" )
            require( "trouble" ).focus()

        -- errors
        elseif res.meta.hasErrors then
            utils.echoe( action .. ": " .. res.status_text )

        -- warnings
        elseif res.meta.hasWarnings then
            utils.echow( action .. ": " .. res.status_text )

        -- ok
        else
            utils.echoc( action .. ": " .. res.status_text )
        end

    end,

    browser = function ( bufnr )
        if not bufnr or bufnr == 0 then
            bufnr = vim.api.nvim_get_current_buf()
        end

        local buffer = utils.get_buffer( bufnr )

        -- buffer is empty
        if buffer == "" then
            utils.echo( "Buffer is empty", "Comment" )

            return
        end

        do_request( bufnr, "softvisio/browser", {
            data = buffer,
            encoding = vim.o.encoding,
            font = vim.g.gfn,
        } )
    end
}

return M;
