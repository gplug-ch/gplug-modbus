import smartmeter
import serversocket
import logger

start_services = def()
    # Start server socket on port 502 (Modbus TCP)
    if serversocket.start(502) == false
        logger.logMsg(logger.lWarn, "Error: cannot start server socket on port 502")
        return
    end

    # Start smartmeter module
    smartmeter.start()
end

stop_services = def()
    # Stop smartmeter module
    smartmeter.stop()

    # Stop server socket
    serversocket.stop()
end

# Start services after 2s (to ensure tasmota module is loaded)
tasmota.set_timer(2000, /-> start_services())

