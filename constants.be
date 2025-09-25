var constants = module()

constants.MODBUS_EXCEPTION_CODES = {
    "01": "Illegal Function",
    "02": "Illegal Data Address",
    "03": "Illegal Data Value",
    "04": "Slave Device Failure",
    "05": "Acknowledge",
    "06": "Slave Device Busy",
    "08": "Memory Parity Error",
    "0A": "Gateway Path Unavailable",
    "0B": "Gateway Target Device Failed to Respond"
}

constants.APP_EXCEPTION_CODES = {
    "E0": "Invalid Command"
}

return constants