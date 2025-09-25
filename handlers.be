var handlers = module()

import strict
import constants
import modbus

def handle_function_code_03(request)
    var registers = []
    var start_reg = request["start_reg"]
    var nr_of_reg = request["nr_of_reg"]
    var act_reg = start_reg
        
    while act_reg < start_reg+nr_of_reg
        var register = modbus.get_register_by_address(str(act_reg))
        register.insert("key", act_reg)
        registers.push(register)
        act_reg += register.item("size")
    end
    return {"response": {
                        "transaction_id": request["transaction_id"],
                        "protocol_id": request["protocol_id"],
                        "length": bytes().add(registers.size()+1,-2),
                        "unit_id": request["unit_id"],
                        "fun_code": request["fun_code"],
                        "nr_of_reg": request["nr_of_reg"],
                        'registers': registers
                        }
                    }
end

var modbus_handlers = {
    '03': / request -> handle_function_code_03(request)
}

def handle_error(result, error_code)
    result.insert("response", {"exception_code": bytes(error_code)})
    return result
end

handlers.check_registers = def(start_reg, nr_of_reg)
    var act_reg = start_reg
    var rest = nr_of_reg
    while act_reg < start_reg+nr_of_reg
        var reg_size = modbus.check_and_get_reg_size_register(str(act_reg))
        if (reg_size == 0) || (rest - reg_size < 0)
            return false
        end
        act_reg += reg_size
        rest -= reg_size
    end
    return true
end

handlers.modbus_handler = def(request)
    # Check requested register addresses are valid
    var start_reg = request["request"].item("start_reg")
    var nr_of_reg = request["request"].item("nr_of_reg")

    if !handlers.check_registers(start_reg, nr_of_reg)
        # Return exception code 02 for illegal data address
        return handle_error(request, "02")  
    end

    # Check if handler exists for the function code
    var fun_code = request["request"].item("fun_code").tohex()
    var res2 = modbus_handlers.contains(fun_code)
    if !modbus_handlers.contains(fun_code)
        # Return exception code 01 for illegal function
        return handle_error(request, "01")   
    end

    # Call the handler for the function code
    return modbus_handlers.item(fun_code)(request["request"])
end

var exception_handlers = {
    constants.MODBUS_EXCEPTION_CODES["01"]: / result -> handle_error(result, "01"),
    constants.MODBUS_EXCEPTION_CODES["02"]: / result -> handle_error(result, "02"),
    constants.MODBUS_EXCEPTION_CODES["03"]: / result -> handle_error(result, "03"),
    constants.MODBUS_EXCEPTION_CODES["04"]: / result -> handle_error(result, "04"),
    constants.MODBUS_EXCEPTION_CODES["05"]: / result -> handle_error(result, "05"),
    constants.MODBUS_EXCEPTION_CODES["06"]: / result -> handle_error(result, "06"),
    constants.MODBUS_EXCEPTION_CODES["08"]: / result -> handle_error(result, "08"),
    constants.MODBUS_EXCEPTION_CODES["0A"]: / result -> handle_error(result, "0A"),
    constants.MODBUS_EXCEPTION_CODES["0B"]: / result -> handle_error(result, "0B")
}

handlers.exception_handler = def(result)
    return exception_handlers.item(result["error"])(result)
end

return handlers