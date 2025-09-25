import strict

import tasmota
import logger
import sunspec
import modbus
import string
import handlers

def setup()
    logger.setLevel(logger.lOff)
    sunspec.load_registers("../")
end

# ---------------------------------------------------
# Test modbus_handler
# ---------------------------------------------------
def test_load_modbus_registers_should_pass()
    setup()
    assert(modbus.get_registers().size() > 0, "Assert: modbus.registers should have more than 0 entries")
end

def test_get_available_register_should_pass()
    setup()
    var value = modbus.get_value_of_register("40004")
    assert(string.startswith(value.item("bytes").asstring(), "GantrischEnergieAG"), "Assert: modbus.get_value_of_register should return a value 'GantrischEnergieAG'")
    assert(value.item("name") == "C_Mn", "Assert: modbus.get_value_of_register should return a value 'C_Mn'")

    value = modbus.get_value_of_register("40020")
    assert(string.startswith(value.item("bytes").asstring(), "gPlugD"), "Assert: modbus.get_value_of_register should return a value 'gPlugD'")
    assert(value.item("name") == "C_Md", "Assert: modbus.get_value_of_register should return a value 'C_Md'")

    value = modbus.get_value_of_register("40070")
    assert(value.item("bytes") ==  bytes('00C9'), "Assert: modbus.get_value_of_register should return a value 00C9 (201)")
    assert(value.item("name") == "M_SunSpecID", "Assert: modbus.get_value_of_register should return a value 'M_SunSpecID'")

    value = modbus.get_value_of_register("40078")
    assert(value.item("bytes") ==  bytes('0000'), "Assert: modbus.get_value_of_register should return a value 0000")
    assert(value.item("name") == "V1", "Assert: modbus.get_value_of_register should return a value 'V1'")

    value = modbus.get_value_of_register("40085")
    assert(value.item("bytes") ==  bytes('0000'), "Assert: modbus.get_value_of_register should return a value 0000")
    assert(value.item("name") == "V_SF", "Assert: modbus.get_value_of_register should return a value 'V_SF'")

    value = modbus.get_value_of_register("40108")
    assert(value.item("bytes") ==  bytes('00000000'), "Assert: modbus.get_value_of_register should return a value 00000000")
    assert(value.item("name") == "Eo", "Assert: modbus.get_value_of_register should return a value 'Eo'")

    value = modbus.get_value_of_register("40177")
    assert(value.item("bytes") ==  bytes('FFFF'), "Assert: modbus.get_value_of_register should return a value FFFF")
    assert(value.item("name") == "EndModel_ID", "Assert: modbus.get_value_of_register should return a value 'EndModel_ID'")

    value = modbus.get_value_of_register("40178")
    assert(value.item("bytes") ==  bytes('0000'), "Assert: modbus.get_value_of_register should return a value 0000")
    assert(value.item("name") == "EndModel_Length", "Assert: modbus.get_value_of_register should return a value 'EndModel_Length'")
end

def test_get_not_available_register_should_not_pass()
    setup()
    var value = modbus.get_value_of_register("40046")
    assert(value == nil, "Assert: modbus.get_value_of_register should return nil")
end

test_load_modbus_registers_should_pass()
test_get_available_register_should_pass()
test_get_not_available_register_should_not_pass()

print("test_modbus passed")