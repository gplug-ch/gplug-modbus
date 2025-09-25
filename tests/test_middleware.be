import strict

import tasmota
import logger
import sunspec
import middleware
import modbus
import handlers

def setup()
    logger.setLevel(logger.lOff)
    sunspec.load_registers("../")
end

var test_response = {'response': 
    {'transaction_id': bytes('0001'), 
    'unit_id': bytes('C9'),
    'fun_code': bytes('03'), 
    'protocol_id': bytes('0000'),
    'nr_of_reg': bytes.add(59,-2),
    'registers': [
            {'key':40070, 'size': 1, 'label': 'Model ID', 'name': 'M_SunSpecID', 'type': 'uint16', 'implementation': 'f', 'fixed_value': '201'}, 
            {'key':40071, 'size': 1, 'label': 'Model Length', 'name': 'M_Length', 'type': 'uint16', 'implementation': 'f', 'fixed_value': '105'}, 
            {'key':40071, 'size': 1, 'label': 'Amps (all phases)', 'name': 'Amps', 'type': 'int16', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40073, 'size': 1, 'label': 'Amps PhaseA', 'name': 'I1', 'type': 'int16', 'implementation': 'v', 'fixed_value': ''}, 
            {'key':40074, 'size': 1, 'label': 'Amps PhaseB', 'name': 'I2', 'type': 'int16', 'implementation': 'v', 'fixed_value': ''}, 
            {'key':40075, 'size': 1, 'label': 'Amps PhaseC', 'name': 'I3', 'type': 'int16', 'implementation': 'v', 'fixed_value': ''}, 
            {'key':40075, 'size': 1, 'label': 'Amps ScaleFactor', 'name': 'I_SF', 'type': 'sunssf', 'implementation': 'f', 'fixed_value': '0000'}, 
            {'key':40077, 'size': 1, 'label': 'Voltage LN', 'name': 'Voltage_LN', 'type': 'int16', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40078, 'size': 1, 'label': 'Phase Voltage AN', 'name': 'V1', 'type': 'int16', 'implementation': 'v', 'fixed_value': ''}, 
            {'key':40079, 'size': 1, 'label': 'Phase Voltage BN', 'name': 'V2', 'type': 'int16', 'implementation': 'v', 'fixed_value': ''}, 
            {'key':40080, 'size': 1, 'label': 'Phase Voltage CN', 'name': 'V3', 'type': 'int16', 'implementation': 'v', 'fixed_value': ''}, 
            {'key':40081, 'size': 1, 'label': 'Voltage LL', 'name': 'PPV', 'type': 'int16', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40082, 'size': 1, 'label': 'Phase Voltage AB', 'name': 'PPVphAB', 'type': 'int16', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40083, 'size': 1, 'label': 'Phase Voltage BC', 'name': 'PPVphBC', 'type': 'int16', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40084, 'size': 1, 'label': 'Phase Voltage CA', 'name': 'PPVphCA', 'type': 'int16', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40085, 'size': 1, 'label': 'Voltage ScaleFacotor', 'name': 'V_SF', 'type': 'sunssf', 'implementation': 'f', 'fixed_value': 'FFFF'}, 
            {'key':40086, 'size': 1, 'label': 'Hz', 'name': 'Hz', 'type': 'int16', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40087, 'size': 1, 'label': 'Hz ScaleFactor', 'name': 'Hz_SF', 'type': 'sunssf', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40088, 'size': 1, 'label': 'Watts (all phases)', 'name': 'Pi', 'type': 'int16', 'implementation': 'v', 'fixed_value': ''}, 
            {'key':40089, 'size': 1, 'label': 'Watts phase A', 'name': 'P1i', 'type': 'int16', 'implementation': 'v', 'fixed_value': ''}, 
            {'key':40090, 'size': 1, 'label': 'Watts phase B', 'name': 'P2i', 'type': 'int16', 'implementation': 'v', 'fixed_value': ''}, 
            {'key':40091, 'size': 1, 'label': 'Watts phase C', 'name': 'P3i', 'type': 'int16', 'implementation': 'v', 'fixed_value': ''}, 
            {'key':40092, 'size': 1, 'label': 'Watts ScaleFactor', 'name': 'P_SF', 'type': 'sunssf', 'implementation': 'f', 'fixed_value': '0000'}, 
            {'key':40093, 'size': 1, 'label': 'VA', 'name': 'VA', 'type': 'int16', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40094, 'size': 1, 'label': 'VA phase A', 'name': 'VAphA', 'type': 'int16', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40095, 'size': 1, 'label': 'VA phase B', 'name': 'VAphB', 'type': 'int16', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40096, 'size': 1, 'label': 'VA phase C', 'name': 'VAphC', 'type': 'int16', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40097, 'size': 1, 'label': 'VA ScaleFactor', 'name': 'VA_SF', 'type': 'sunssf', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40098, 'size': 1, 'label': 'VAR', 'name': 'VAR', 'type': 'int16', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40099, 'size': 1, 'label': 'VAR phase A', 'name': 'VARphA', 'type': 'int16', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40100, 'size': 1, 'label': 'VAR phase B', 'name': 'VARphB', 'type': 'int16', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40101, 'size': 1, 'label': 'VAR phase C', 'name': 'VARphC', 'type': 'int16', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40102, 'size': 1, 'label': 'VAR ScaleFactor', 'name': 'VAR_SF', 'type': 'sunssf', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40103, 'size': 1, 'label': 'PF', 'name': 'PF', 'type': 'int16', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40104, 'size': 1, 'label': 'PF phase A', 'name': 'PFphA', 'type': 'int16', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40105, 'size': 1, 'label': 'PF phase B', 'name': 'PFphB', 'type': 'int16', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40106, 'size': 1, 'label': 'PF phase C', 'name': 'PFphC', 'type': 'int16', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40107, 'size': 1, 'label': 'PF ScaleFactor', 'name': 'PF_SF', 'type': 'sunssf', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40108, 'size': 2, 'label': 'Total Watt-hours Exported', 'name': 'Eo', 'type': 'acc32', 'implementation': 'v', 'fixed_value': ''}, 
            {'key':40110, 'size': 2, 'label': 'Total Watt-hours Exported phase A', 'name': 'TotWhExpPhA', 'type': 'acc32', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40112, 'size': 2, 'label': 'Total Watt-hours Exported phase B', 'name': 'TotWhExpPhB', 'type': 'acc32', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40114, 'size': 2, 'label': 'Total Watt-hours Exported phase C', 'name': 'TotWhExpPhC', 'type': 'acc32', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40116, 'size': 2, 'label': 'Total Watt-hours Imported', 'name': 'Ei', 'type': 'acc32', 'implementation': 'v', 'fixed_value': ''}, 
            {'key':40118, 'size': 2, 'label': 'Total Watt-hours Imported phase A', 'name': 'TotWhImpPhA', 'type': 'acc32', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40120, 'size': 2, 'label': 'Total Watt-hours Imported phase B', 'name': 'TotWhImpPhB', 'type': 'acc32', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40122, 'size': 2, 'label': 'Total Watt-hours Imported phase C', 'name': 'TotWhImpPhC', 'type': 'acc32', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40124, 'size': 1, 'label': 'Total Watt-hours ScaleFactor', 'name': 'TotWh_SF', 'type': 'sunssf', 'implementation': 'f', 'fixed_value': 'FFFD'}, 
            {'key':40125, 'size': 2, 'label': 'Total VA-hours Exported', 'name': 'TotVAhExp', 'type': 'acc32', 'implementation': 'NI', 'fixed_value': ''}, 
            {'key':40127, 'size': 2, 'label': 'Total VA-hours Exported phase A', 'name': 'TotVAhExpPhA', 'type': 'acc32', 'implementation': 'NI', 'fixed_value': ''} 
        ]
    }
}

# ---------------------------------------------------
# Test decoding
# ---------------------------------------------------
def test_decode_with_function_code_03_should_pass()
    # Supported function code '03' (Read Input Registers)
    var bytes_request = bytes("000100000006C9039C85003C")
    var request = middleware.decode(bytes_request)
    # Check request
    assert(request != nil, "Assert: request cannot be nil")
    assert(request["request"] != nil, "Assert: request cannot be nil")
    assert(request["error"] == nil, "Assert: error should be nil")
end

def test_decode_with_function_code_05_should_not_pass()
    # Not supported function code '05' (Write Single Coil)
    bytes_request = bytes("000100000006C9059C85003C")
    request = middleware.decode(bytes_request)

    # Check request
    assert(request != nil, "Assert: request cannot be nil")
    assert(request["request"] != nil, "Assert: request cannot be nil")
    assert(request["error"] != nil, "Assert: error cannot be nil")
end

test_decode_with_function_code_03_should_pass()
test_decode_with_function_code_05_should_not_pass()

print("tests decode passed")

# ---------------------------------------------------
# Test encode
# ---------------------------------------------------
def test_encode_with_function_code_03_should_pass()
    setup()
    var bytes_response = middleware.encode(test_response)

    # Check response
    assert(bytes_response != nil, "Assert: bytes_response cannot be nil")
end

def test_encode_with_function_code_05_should_not_pass()
    # Not supported function code '05' (Write Single Coil)
    bytes_request = bytes("000100000006C9059C85003C")
    error_request = middleware.decode(bytes_request)

    # Check error_request
    assert(error_request != nil, "Assert: error_request cannot be nil")
    assert(error_request["error"] != nil, "Assert: error cannot be nil")
    assert(error_request["response"]["exception_code"] != nil, "Assert: exception_code cannot be nil")

    var bytes_response = middleware.encode(error_request)

    # Check response
    assert(bytes_response != nil, "Assert: bytes_response cannot be nil")
    
    # Check function code is 0x80 + original function code
    var function_code = bytes_response[7..7]
    assert(function_code == bytes('85'), "Assert: function_code should be '85')")
end

test_encode_with_function_code_03_should_pass()
test_encode_with_function_code_05_should_not_pass()

print("tests encode passed")