var modbus = module()

import strict
import json
import string
import sunspec
import obiscode
import smartmeter

modbus.get_registers = def()
    return sunspec.get_registers()
end

modbus.check_and_get_reg_size_register = def(address)
    var registers = sunspec.get_registers()

    if registers.contains(address)
        var register = registers.find(address)
        return register.item("size")
    else
        return 0
    end
end

modbus.get_register_by_address = def(address)
    var registers = sunspec.get_registers()

    if registers.contains(address)
        return registers.find(address)
    else
        return nil
    end
end

modbus.get_value_of_register = def(address)
    var registers = sunspec.get_registers()

    if registers.contains(address)
        var register = registers.find(address)
        var modbus_name = register.item("name")
        var modbus_type = register.item("type")

        if string.startswith(modbus_name, "SunSpec") || string.startswith(modbus_name, "EndModel")
            var value = register.item("fixed_value")
            var item_size = register.item("size")
            var int_bytes = bytes(value, -item_size*2)
            return {"name": modbus_name, "bytes": int_bytes}
        elif modbus_type == "string"
            var value = register.item("fixed_value")
            var item_size = register.item("size")
            var str_bytes = bytes().fromstring(value).resize(2*item_size)
            return {"name": modbus_name, "bytes": str_bytes}
        else
            var value
            if modbus_type == "float32"
                var fv = register.item("fixed_value")
                value = size(fv) > 0 ? real(fv) : 0.0
            else
                value = int(register.item("fixed_value"))
            end
            var obis_code = register.item("obis_code")
            if size(obis_code) > 0
                var entry = obiscode.get_smartmeter_code(obis_code)
                if size(entry) > 0
                    var code = entry["code"]
                    var scale_factor = entry["scale"]
                    var data = smartmeter.get_data()
                    if string.find(code, '/') > 0 
                        var arr = string.split(code, '/')
                        # get value of direction "in"
                        var sign = string.endswith(arr[0],'i', true) == true ? 1 : -1
                        value = sign * data.find(arr[0], 0)
                        if value == 0
                            # get value of direction "out"
                            sign = string.endswith(arr[1],'o', true) == true ? -1 : 1
                            value = sign * data.find(arr[1], 0)
                        end
                    else
                        value = data.find(code, 0)
                    end
                    value = value * scale_factor
                end
            end
            var item_size = register.item("size")
            if modbus_type == "float32"
                var float_bytes = bytes(-4)
                float_bytes.setfloat(0, real(value))
                # Reverse for big-endian (Modbus byte order)
                var be_bytes = bytes(-4)
                be_bytes[0] = float_bytes[3]
                be_bytes[1] = float_bytes[2]
                be_bytes[2] = float_bytes[1]
                be_bytes[3] = float_bytes[0]
                return {"name": modbus_name, "bytes": be_bytes}
            else
                var int_bytes = bytes().add(int(value), -item_size*2)
                return {"name": modbus_name, "bytes": int_bytes}
            end
        end
    else
        return nil
    end
end

return modbus