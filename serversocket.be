var serversocket = module()

import strict
import clientsocket
import logger

var server = nil

class ServerSocket
    var id
    var listener

    def init(server_port)
        assert(server_port != nil, "Error: server_port property cannot be nil")

        self.id = "server-socket"

        try
            self.listener = tcpserver(server_port)
        except .. as e
            logger.logMsg(logger.lWarn, f"Error: port {server_port} in use")
            return false  # Port is in use!
        end

        tasmota.add_driver(self)
        logger.logMsg(logger.lInfo, f"Modbus server listening on port {server_port}")
        return true
    end

    def every_100ms()  # 10 Hz
        if self.listener.hasclient() == false
            return
        end

        var acc_sock = self.listener.accept()
        assert(acc_sock.connected() == true, "Error: client not connected successfully")

        # Create a new ClientSocket
        clientsocket.start(acc_sock)
        logger.logMsg(logger.lDebug, "New remote client has connected")
    end

    def shutdown()
        tasmota.remove_driver(self)
        self.listener.close()
        self.listener = nil
        logger.logMsg(logger.lDebug, f"ServerSocket '{self.id}' closed")
    end

    def deinit()
        self.shutdown()
    end
end


serversocket.start = def(server_port)
    server = ServerSocket(server_port)
    if server.listener == nil
        return false
    end
    return true
end

serversocket.stop = def()
    if server != nil
        server.shutdown()
        server = nil
    end
end

return serversocket