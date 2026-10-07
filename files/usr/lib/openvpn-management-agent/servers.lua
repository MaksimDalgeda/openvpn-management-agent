local uci = require("uci").cursor()

local M = {}

function M.get_servers()

    local servers = {}

    uci:foreach("openvpn", nil, function(section)

        if section.mode == "server" then

            local extra = table.concat(section.extra or {}, " ")

            local ip, port =
                string.match(
                    extra,
                    "management%s+(%S+)%s+(%d+)"
                )

            table.insert(servers, {
                sec_id = section[".name"],
                name = section.name,
                management_ip = ip,
                management_port = tonumber(port)
            })
        end
    end)

    return servers
end

return M