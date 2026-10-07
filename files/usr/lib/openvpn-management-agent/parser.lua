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
                common_name = f[2],
                real_address = f[3],
                virtual_address = f[4],
                bytes_received = tonumber(f[6]),
                bytes_sent = tonumber(f[7]),
                connected_since = f[8],
                connected_since_unix = tonumber(f[9]),
                username = f[10],
                client_id = tonumber(f[11]),
                peer_id = tonumber(f[12]),
                cipher = f[13]
            })
        end
    end

    return clients
end

return M