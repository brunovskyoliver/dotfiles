
local ICON = '📡'
_G.statusline = function()
    local ok, plugin = pcall(require, 'distant')

    if not ok or not plugin:is_initialized() or not plugin.buf.has_data() then
        return ''
    end

    local destination = assert(plugin:client_destination(plugin.buf.client_id()))
    return ('%s %s'):format(ICON, destination.host)
end

return {

    'chipsenkbeil/distant.nvim',
    branch = 'v0.3',
    config = function()
        require('distant'):setup()
    end
}
