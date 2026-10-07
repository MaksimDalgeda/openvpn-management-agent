local M = {}

function M.log_info(message)
    os.execute(
        string.format(
            'logger -t openvpn-management-agent "[INFO] %s"',
            message
        )
    )
end

function M.log_error(message)
    os.execute(
        string.format(
            'logger -t openvpn-management-agent "[ERROR] %s"',
            message
        )
    )
end

return M