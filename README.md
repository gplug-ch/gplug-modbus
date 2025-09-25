# Modbus-TCP Server on gPlug

## Specifications

Following documents are important to understand:

- [MODBUS APPLICATION PROTOCOL SPECIFICATION
V1.1b3](https://www.afs.enea.it/project/protosphera/Proto-Sphera_Full_Documents/mpdocs/docs_EEI/Modbus_Application_Protocol_V1_1b3.pdf)

- *Chapter 6 Device Information Model Usage for Modbus* of the [SunSpec Device Information Model
Specification](https://sunspec.org/wp-content/uploads/2025/01/SunSpec-Device-Information-Model-Specificiation-V1-2-1-1.pdf)

## @home

Use [mbpoll](https://github.com/epsilonrt/mbpoll) as modbus client. Example:

```shell
mbpoll -v -t 4 -1 -0 -p 502 -a 201 -r 40070 -c 59 gplugk.local |   { while read R; do echo "$(date +%T\ %N) $R"; done }
```

## Description

This project implements a lightweight Modbus-TCP server in Berry Script Language on the gPlug device, based on ESP32-C3 with [Tasmota firmware](https://tasmota.github.io/docs/).
The server is capable of serving SmartMeter data via user-defined register mapping that allows adapting to proprietary or SunSpec-compatible layouts.

Key features:

- Functional Modbus-TCP server supporting functioncode 3
- Implemented with [Berry Scripting Language](https://berry-lang.github.io/) inside Tasmota firmware
- User-defined register mapping via `user-mapping.json`-File

## Installation

1. **Requirements**
   - gPlug with Tasmota firmware (≥ v14.5.0) and Berry scripting support
   - A SmartMeter from your local service provider with accessible data on the customer interface

2. **Upload the source files**
   - Upload the compressed `.tapp` file to the gPlug using the Tasmota web interface or other methods (eg. HTTP/MQTT)
   - Make sure `UserInput.json` is present and correctly formatted.
   - To load the `.tapp` file correctly, restart the Berry-VM with `brrestart` in the tasmota console

3. **Enable the Server**
   - The Modbus-Server starts automatically after approx. 7.5 sec.
   - You can stop and start the Mosbus-Server with `MB_Server.stop()` or `MB_Server.start()` in the berry console

### Build your own code

To build the needed `.tapp` file, you need to build the `Makefile` with GNU Make V4.3.
