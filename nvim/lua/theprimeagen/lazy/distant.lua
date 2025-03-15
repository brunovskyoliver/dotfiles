
local ICON = '📡'

-- Returns a statusline-compatible string
local function statusline()
    -- Attempt to load the distant.nvim plugin
    local ok, plugin = pcall(require, 'distant')

    -- Check the following to see if we are in a remote buffer
    --
    -- 1. Can the plugin be found?
    -- 2. Is the plugin initialized?
    -- 3. Does the buffer have remote data associated?
    --
    -- If the answer to any of these questions is no, we return
    -- an empty string to avoid putting anything in our statusline
    if not ok or not plugin:is_initialized() or not plugin.buf.has_data() then
        return ''
    end

    -- At this point, we know that we have a remote buffer,
    -- and we want to look up what server is represented,
    -- which we do by retrieving a destination table that
    -- contains a host string we can include alongside
    -- a custom emoji
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
