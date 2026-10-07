local ubus = require("ubus")
local servers = require("servers")
local management = require("management")
local parser = require("parser")
local logger = require("logger")

local M = {}

local function make_ubus_objects(conn)
    local objects = {}

    for _, srv in ipairs(servers.get_servers()) do

        objects["openvpn." .. srv.name] = {

            list = {
                function(req)
                    local lines, err =
                        management.status(
                            srv.management_ip,
                            srv.management_port
                        )

                    if not lines then
                        logger.log_error(
                            "Failed to get status from " ..
                            srv.name .. ": " .. tostring(err)
                        )

                        return conn:reply(req, {
                            success = false,
                            error = err
                        })
                    end

                    local clients = parser.clients(lines)

                    conn:reply(req, {
                        name = srv.name,
                        clients = clients
                    })
                end,
                {}
            },

            disconnect = {
                function(req, msg)

                    local lines, err =
                        management.status(
                            srv.management_ip,
                            srv.management_port
                        )

                    if not lines then
                        return conn:reply(req, {
                            success = false,
                            error = err
                        })
                    end

                    local clients = parser.clients(lines)
                    local cid

                    for _, client in ipairs(clients) do
                        if client.real_address == msg.ip_addr then
                            cid = client.client_id
                            break
                        end
                    end

                    if not cid then
                        return conn:reply(req, {
                            success = false,
                            error = "client not found"
                        })
                    end

                    local response, err =
                        management.disconnect(
                            srv.management_ip,
                            srv.management_port,
                            cid
                        )

                    local ok = response ~= nil

                    conn:reply(req, {
                        success = ok,
                        error = err
                    })
                end,
                {
                    ip_addr = ubus.STRING
                }
            }
        }
    end

    return objects
end

function M.create_objects(conn)
    return make_ubus_objects(conn)
end

return M