package.path ="/usr/lib/openvpn-management-agent/?.lua;" .. package.path

local management = require("management")

print("OpenVPN Management Agent started")

management.test()