import strict

import tasmota
import handlers
import modbus
import sunspec
import logger

def setup()
    logger.setLevel(logger.lOff)
    sunspec.load_registers("../")
end

# ---------------------------------------------------
# Test handler
# ---------------------------------------------------
def test_load_modbus_registers_should_pass()
    setup()
    assert(modbus.get_registers().size() > 0, "Assert: modbus.registers should have more than 0 entries")
end

def test_register_address()
    setup()
    # start with 40070 (size 1)
    assert(handlers.check_registers(40070, 1), "Assert: handlers.check_registers should return true")
    assert(handlers.check_registers(40070, 2), "Assert: handlers.check_registers should return true")
    assert(handlers.check_registers(40070, 4), "Assert: handlers.check_registers should return true")
    
    # start with 40114 (size 2)
    assert(handlers.check_registers(40114, 2), "Assert: handlers.check_registers should return true")
    assert(handlers.check_registers(40114, 4), "Assert: handlers.check_registers should return true")
    assert(handlers.check_registers(40114, 6), "Assert: handlers.check_registers should return true")
    assert(handlers.check_registers(40114, 1) == false, "Assert: handlers.check_registers should return false")
    assert(handlers.check_registers(40114, 3) == false, "Assert: handlers.check_registers should return false")
    assert(handlers.check_registers(40114, 5) == false, "Assert: handlers.check_registers should return false")

    # start with 40070 and read 60 registers (last is 40128)
    assert(handlers.check_registers(40070, 59), "Assert: handlers.check_registers should return true")
    assert(handlers.check_registers(40070, 60) == false, "Assert: handlers.check_registers should return false")
end

def test_handler_func03_should_pass()
    setup()
    var request = {
        "request": {
        'protocol_id': bytes('0000'), 
        'start_reg': 40070,
        'nr_of_reg': 59, 
        'unit_id': bytes('C9'), 
        'fun_code': bytes('03'), 
        'transaction_id': bytes('0001'), 
        'length': bytes('0006'), 
        'pdu': bytes('049C85003C')}
    }
    var response = handlers.modbus_handler(request)
    var registers = response["response"]['registers']
    assert(registers[0].item('key') == 40070, "Assert: handlers.modbus_handler should return register 40070")
    assert(registers[1].item('key') == 40071, "Assert: handlers.modbus_handler should return register 40071")
end

def test_handler_func03_should_fail_with_exception()
    setup()
    var request = {
        "request": {
        'protocol_id': bytes('0000'), 
        'start_reg': 40070,
        'nr_of_reg': 60, 
        'unit_id': bytes('C9'), 
        'fun_code': bytes('03'), 
        'transaction_id': bytes('0001'), 
        'length': bytes('0006'), 
        'pdu': bytes('049C85003C')}
    }
    var response = handlers.modbus_handler(request)
    assert(response["response"].contains("exception_code"), "Assert: handlers.modbus_handler should return exception_code")
    var exception_code = response["response"]["exception_code"]
    assert(exception_code == bytes("02"), "Assert: handlers.modbus_handler should return exception_code 02")
end

def test_handler_func05_should_fail_with_exception()
    setup()
    var request = {
        "request": {
        'protocol_id': bytes('0000'), 
        'start_reg': 40070,
        'nr_of_reg': 59, 
        'unit_id': bytes('C9'), 
        'fun_code': bytes('05'), 
        'transaction_id': bytes('0001'), 
        'length': bytes('0006'), 
        'pdu': bytes('049C85003C')}
    }
    var response = handlers.modbus_handler(request)
    assert(response["response"].contains("exception_code"), "Assert: handlers.modbus_handler should return exception_code")
    var exception_code = response["response"]["exception_code"]
    assert(exception_code == bytes("01"), "Assert: handlers.modbus_handler should return exception_code 01")
end

test_load_modbus_registers_should_pass()
test_register_address()
test_handler_func03_should_pass()
test_handler_func03_should_fail_with_exception()
test_handler_func05_should_fail_with_exception()

print("test_handler passed")