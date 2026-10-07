local M = {}

local function split(text)
    local fields = {}

    for field in (text .. ","):gmatch("(.-),") do
        table.insert(fields, field)
    end

    return fields
end

function M.clients(lines)
    local clients = {}

    for _, line in ipairs(lines) do
        if line:match("^CLIENT_LIST") then
            local f = split(line)

            table.insert(clients, {
                ip_addr = f[3],
                common_name = f[2],
                virtual_address = f[4],
                bytes_received = tonumber(f[6]),
                bytes_sent = tonumber(f[7]),
                connected_since = f[8],
                client_id = tonumber(f[11])
            })
        end
    end

    return clients
end

return M