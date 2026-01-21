var middleware = module()

import strict
import constants
import handlers
import modbus

#
# Decode shall return a map with either "request" or "error"
#
middleware.decode = def(msg)
    var MAX_REGISTERS = 125  # Modbus spec limit for function code 3

    def decode_mbap(msg)
        # Validate minimum message length (MBAP header is 7 bytes + at least 1 byte PDU)
        if msg.size() < 8
            return {"request": nil, "error": constants.APP_EXCEPTION_CODES}
        end

        var request = map()

        request.insert("transaction_id", msg[0..1])
        request.insert("protocol_id", msg[2..3])
        request.insert("length", msg[4..5])
        request.insert("unit_id", msg[6..6])
        request.insert("pdu", msg[7..])

        if request["protocol_id"] != bytes("0000")
            # Not a modbus request, discard!
            return {"request": nil, "error": constants.APP_EXCEPTION_CODES}
        else
            return {"request": request, "error": nil}
        end
    end

    def decode_pdu(msg)
        var request = msg["request"]
        var pdu = request["pdu"]
        request.insert("fun_code", pdu[0..0])
        request.insert("start_reg", pdu[1..2].get(0,-2)) # register address space starts with 0
        request.insert("nr_of_reg", pdu[3..4].get(0,-2))

        if (request.item("fun_code") != bytes("03"))
            return {"request": request, "error": constants.MODBUS_EXCEPTION_CODES["01"]}
        end

        # Validate register count (Modbus spec limit: 125 for function code 3)
        if request.item("nr_of_reg") > MAX_REGISTERS || request.item("nr_of_reg") < 1
            return {"request": request, "error": constants.MODBUS_EXCEPTION_CODES["03"]}
        end

        return msg
    end

    # Check msg
    assert(msg != nil, "Error: msg cannot be nil")
    
    # Call decoders
    var decoded_msg = decode_mbap(msg)
    if decoded_msg["error"] != nil
        return handlers.exception_handler(decoded_msg)
    end

    decoded_msg = decode_pdu(decoded_msg)
    if decoded_msg["error"] != nil
        return handlers.exception_handler(decoded_msg)
    end

    return decoded_msg
end

#
# Encode shall return the encoded bytes
#
middleware.encode = def(msg)

    def encode_mbap(response, encoded_pdu)
        var header =  response["transaction_id"] .. response["protocol_id"] .. response["length"] .. response["unit_id"]
        var mbap = header .. encoded_pdu
        return mbap
    end

    def encode_registers(registers)
        var data = bytes()
        for reg: registers
            var val = modbus.get_value_of_register(str(reg['key']))
            if val != nil && val.item("bytes") != nil
                data = data .. val.item("bytes")
            else
                # Return zero bytes for unknown registers
                data = data .. bytes("0000")
            end
        end
        return data
    end

    def encode_pdu(msg)
        var response = msg["response"]
        var registers = response['registers']
        var data = encode_registers(registers)
        var nr_registers = response["nr_of_reg"]
        var nr_bytes = bytes().add(nr_registers*2, -1)
        var pdu = response["fun_code"] .. nr_bytes .. data
        return pdu 
    end

    def encode_error_pdu(msg)
        var response = msg["response"]
        var request = msg["request"]
        # Set the error code by setting the highest bit of the function code
        var error_code = bytes().add(request["fun_code"][0] | 0x80)
        var pdu = error_code .. response["exception_code"]
        return pdu 
    end

    # Check msg
    assert(msg != nil, "Error: msg cannot be nil")
    if msg.contains("error") == false
        # Call encoders
        var encoded_pdu = encode_pdu(msg)
        msg["response"].setitem("length", bytes().add(encoded_pdu.size() + 1, -2))
        var encoded_mbap = encode_mbap(msg["response"], encoded_pdu)
        return encoded_mbap
    else
        # Handle error
        var encoded_pdu = encode_error_pdu(msg)
        var encoded_mbap = encode_mbap(msg["request"], encoded_pdu)
        return encoded_mbap
    end
end

return middleware