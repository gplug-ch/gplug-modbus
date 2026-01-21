# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A lightweight Modbus-TCP server in Berry Script for gPlug (ESP32-C3) running Tasmota firmware. Exposes SmartMeter/SunSpec data via Modbus protocol (function code 3 only: Read Holding Registers).

## Build Commands

```bash
make          # Clean and build .tapp file
make tapp     # Build .tapp only
make test     # Run unit tests (requires Berry interpreter)
make upload   # Upload to device (requires IP_TASMOTA_DEVICE in .env)
make clean    # Remove build artifacts
```

## Testing

**Unit tests:** Run with `make test`. Tests are in `tests/` directory. Mock Tasmota functions are in `tests/tasmota.be`.

**Integration tests:** Use `tools/load_test/load_test.py` for concurrent Modbus client testing (requires `mbpoll` client).

## Architecture

Request flow:
```
TCP (port 502) → ServerSocket → ClientSocket.handle_request()
  → middleware.decode() → handlers.modbus_handler()
    → modbus.get_value_of_register() → smartmeter.get_data()
  → middleware.encode() → TCP Response
```

Key components:
- `main.be` - Service startup/shutdown entry point
- `serversocket.be` / `clientsocket.be` - TCP networking layer
- `middleware.be` - Modbus MBAP + PDU encode/decode
- `handlers.be` - Request routing by function code
- `modbus.be` - Register access and value retrieval
- `smartmeter.be` - SmartMeter data acquisition (singleton, polls every 10s)
- `sunspec.be` - Register definition loader from JSON (singleton)
- `obiscode.be` - OBIS code mapping to smartmeter fields

## Key Patterns

- **Tasmota Driver Pattern:** Server/Client sockets register as Tasmota drivers for periodic execution (50ms client poll, 100ms server accept)
- **Singleton Pattern:** `smartmeter.be` and `sunspec.be` maintain stateful singletons
- **Module Pattern:** All components use `module()` for namespacing

## Configuration

- `sunspec.json` - Default register definitions (SunSpec format)
- `user-mapping.json` - Custom register mapping (loaded if present, else falls back to sunspec.json)
- `.env` - Device IP for uploads (`IP_TASMOTA_DEVICE`)

## Constraints

- Port 502 hardcoded (Modbus standard)
- Only function code 3 (Read Holding Registers) supported
- Berry script runs on resource-constrained ESP32-C3

## Berry Language Reference

Full specification: `../specs/BERRY_LANGUAGE_REFERENCE.txt`

Key syntax for this codebase:

```berry
# Module pattern (used by all components)
module("modulename")

# Class definition
class MyClass
    var field1, field2
    def init(arg)
        self.field1 = arg
    end
    def method()
        return self.field1
    end
end

# Singleton pattern
var _instance = nil
def get_instance()
    if _instance == nil
        _instance = MyClass()
    end
    return _instance
end

# Map operations (used for register lookups)
m = {"key": "value"}
m["key"]                    # Access
m.find("key", default)      # Access with default
m.contains("key")           # Check existence

# Bytes operations (used for Modbus PDU)
b = bytes()
b.add(value, num_bytes)     # Append bytes
b.get(offset, num_bytes)    # Read unsigned (little endian)
b.get(offset, -num_bytes)   # Read unsigned (big endian)
b.geti(offset, num_bytes)   # Read signed

# String formatting
string.format("Value: %d", 42)
f"Value: {x}"               # f-string

# JSON parsing
import json
data = json.load('{"key": "value"}')  # Returns nil on error

# Exception handling
try
    # code
except .. as e, msg
    # catch all
end
```

Tasmota-specific APIs used:
- `tasmota.add_driver(driver)` - Register periodic execution
- `tasmota.remove_driver(driver)` - Unregister driver
- `tasmota.set_timer(ms, callback)` - One-shot timer
- `tasmota.add_cron(cron_expr, callback)` - Scheduled execution
- `tasmota.read_sensors()` - Get sensor data as JSON string
- `tcpserver(port)` - Create TCP server socket
