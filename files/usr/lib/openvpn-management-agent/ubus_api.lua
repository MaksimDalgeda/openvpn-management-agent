local ubus = require("ubus")
local servers = require("servers")
local management = require("management")
local parser = require("parser")
local logger = require("logger")

local M = {}

local function get_clients(srv)
    local lines, err = management.status(
        srv.management_ip,
        srv.management_port
    )

    if not lines then
        logger.log_error(
            "Failed to get status from " ..
            srv.name .. ": " .. tostring(err)
        )

        return nil, err
    end

    return parser.clients(lines)
end

local function make_ubus_objects(conn)
    local objects = {}

    for _, srv in ipairs(servers.get_servers()) do
        local server = srv

        objects["openvpn." .. server.name] = {

            list = {
                function(req)
                    local clients, err = get_clients(server)

                    if not clients then
                        return conn:reply(req, {
                            success = false,
                            error = err
                        })
                    end

                    local result = {}

                    for _, client in ipairs(clients) do
                        table.insert(result, {
                            ip_addr = client.ip_addr,
                            common_name = client.common_name,
                            virtual_address = client.virtual_address,
                            bytes_received = client.bytes_received,
                            bytes_sent = client.bytes_sent,
                            connected_since = client.connected_since
                        })
                    end

                    conn:reply(req, {
                        name = server.name,
                        clients = result
                    })
                end,
                {}
            },

            disconnect = {
                function(req, msg)
                    local clients, err = get_clients(server)

                    if not clients then
                        return conn:reply(req, {
                            success = false,
                            error = err
                        })
                    end

                    local cid

                    for _, client in ipairs(clients) do
                        if client.ip_addr == msg.ip_addr then
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

                    logger.log_info(
                        "Disconnecting " ..
                        msg.ip_addr ..
                        " from " ..
                        server.name ..
                        " CID=" ..
                        tostring(cid)
                    )

                    local response, disconnect_err =
                        management.disconnect(
                            server.management_ip,
                            server.management_port,
                            cid
                        )

                    local success = response ~= nil

                    if not success then
                        logger.log_error(
                            "Failed to disconnect " ..
                            msg.ip_addr .. ": " ..
                            tostring(disconnect_err)
                        )
                    end

                    conn:reply(req, {
                        success = success,
                        error = disconnect_err
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