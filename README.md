# OpenVPN Management Agent

A Lua-based OpenWRT service for monitoring and managing OpenVPN servers through the OpenVPN Management Interface.

## Features

- Monitor connected OpenVPN clients
- Disconnect active VPN clients
- ubus integration
- REST API integration
- Multi-server support
- OpenWRT package
- Procd init service

## Architecture

The service communicates with OpenVPN servers through the OpenVPN Management Interface to collect real-time information about connected clients and execute administrative actions, such as client disconnection.

For each running OpenVPN server instance, the service creates a dedicated ubus object, allowing other OpenWRT applications and services to retrieve server information and manage active VPN sessions.

Additionally, the project exposes REST API endpoints that provide centralized access to OpenVPN server data, including available servers, connected clients, and client management operations.

The solution is designed to support multiple OpenVPN server instances running simultaneously on the same device.