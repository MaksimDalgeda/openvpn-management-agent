local socket = require("socket")

local M = {}

local function command(ip, port, cmd)

    local client = socket.tcp()
    client:settimeout(5)

    local ok, err = client:connect(ip, port)

    if not ok then
        client:close()
        return nil, err
    end

    client:receive("*l")
    client:send(cmd .. "\r\n")

    local response = {}

    while true do

        local line, err = client:receive("*l")

        if not line then
            client:close()
            return nil, err
        end

        table.insert(response, line)

        if line == "END" then
            break
        end

        -- client-kill atsakymas neturi END
        if cmd:match("^client%-kill") then
            break
        end
    end

    client:close()

    return response
end

function M.status(ip, port)
    return command(ip, port, "status 2")
end

function M.disconnect(ip, port, cid)
    return command(ip, port, "client-kill " .. cid)
end

return M