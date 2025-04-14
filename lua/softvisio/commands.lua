local M = {}

function M.setup ()
    vim.api.nvim_create_user_command( "S", M.execute, {
        nargs = "*",
        complete = M.complete,
        desc = "Softvisio LSP",
    } )
end

function M.execute ( input )
end

function M.complete ( ... )
end

return M
