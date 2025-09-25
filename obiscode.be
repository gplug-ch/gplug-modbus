var obiscode = module()
import strict

var codes = {
    "1.7.0": {"code": "Pi/Po", "scale": 1000},
    "21.7.0": {"code": "P1i/P1o", "scale": 1},
    "41.7.0": {"code": "P2i/P2o", "scale": 1},
    "61.7.0": {"code": "P3i/P3o", "scale": 1},
    "32.7.0": {"code": "V1", "scale": 1},
    "52.7.0": {"code": "V2", "scale": 1},
    "72.7.0": {"code": "V3", "scale": 1},
    "31.7.0": {"code": "I1", "scale": 1},
    "51.7.0": {"code": "I2", "scale": 1},
    "71.7.0": {"code": "I3", "scale": 1},
    "3.7.0": {"code": "rPi/rPo", "scale": 1},
    "33.7.0": {"code": "pf1", "scale": 1},
    "1.8.0": {"code": "Ei", "scale": 10},
    "2.8.0": {"code": "Eo", "scale": 10},
    "3.8.0": {"code": "rEi", "scale": 10},
    "4.8.0": {"code": "rEo", "scale": 10}
}

obiscode.get_smartmeter_code = def(obis_code)
    var code = codes.find(obis_code, "")
    return code
end

return obiscode