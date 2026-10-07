package.path = "/usr/lib/openvpn-management-agent/?.lua;" ..
    package.path

local ubus = require("ubus")
local uloop = require("uloop")
local api = require("ubus_api")

uloop.init()

local conn = ubus.connect()

if not conn then
    error("Failed to connect to ubus")
end

conn:add(api.create_objects(conn))

uloop.run()

conn:close()