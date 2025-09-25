# Modbus-TCP Server on gPlug

## Specifications

Following documents are important to understand:

- [MODBUS APPLICATION PROTOCOL SPECIFICATION
V1.1b3](https://www.afs.enea.it/project/protosphera/Proto-Sphera_Full_Documents/mpdocs/docs_EEI/Modbus_Application_Protocol_V1_1b3.pdf)

- *Chapter 6 Device Information Model Usage for Modbus* of the (SunSpec Device Information Model
Specification)[https://sunspec.org/wp-content/uploads/2025/01/SunSpec-Device-Information-Model-Specificiation-V1-2-1-1.pdf]

## @home

Use [mbpoll](https://github.com/epsilonrt/mbpoll) as modbus client. Example:

```shell
mbpoll -v -t 4 -1 -0 -p 502 -a 201 -r 40070 -c 59 gplugk.local |   { while read R; do echo "$(date +%T\ %N) $R"; done }
```

## Description

This project implements a lightweight Modbus-TCP server in Berry Script Language on the gPlug device, based on ESP32-C3 with [Tasmota firmware](https://tasmota.github.io/docs/).
The server is capable of serving SmartMeter data via user-defined register mapping that allows adapting to proprietary or SunSpec-compatible layouts.

Key features:

- Functional Modbus-TCP server supporting functioncode 3 and 4
- Implemented with [Berry Scripting Language](https://berry-lang.github.io/) inside Tasmota firmware
- User-defined register mapping via `UserInput.json`-File
- Finite State Machine (FSM) for Modbus protocol specific handling
- BiCoNaCo-based modular communication framework (Socket- and Protocolhandling is separated)
- Client connection tracking and automatic cleanup

### General application architecture

The system is built on a modular architecture using the BiCo-NaCo communication framework, which allows for separation between the socket- and the protocolhandling-layer. Each Modbus-TCP client connection is handled independently through a Communication Handling Structure to which the client is attached to.

The protocolhandling-layer creates a Finit State Machine (FSM) which coordinates protocol parsing and response generation. The data register access is handeld by a separate class (MB_RegOrganizer) which grants access to the register memory.

The following diagram illustrates an abstract high-level architecture of the system:
![Systemarchitecture Diagram](ZZ_Playground/Images/Systemarch_Diagramm.jpg)

#### Finit State Machine

The FSM is created and being processed by the MB_FSMCreator and the MB_FSMExecutor classes. The following diagram shows the steps every incoming traffic on Port 502 is put trough.

Following diagramm shows the steps of the FSM:
![FSM Overview](ZZ_Playground/Images/FSM%20ModbusTCP.jpg)

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

## Usage

### Configuration of UserInput.json

The UserInput.json file defines the Register-Settings.

There are two kinds of stored Data in the Modbus-Register. For both kinds the user is not allowed to change the property-names except for the `"VariableTag"`-property.

#### Variable Register-Data

- Modbus-Registers, which should be updated by SM-Data, must have set `"VariableTag"` identical to one identifier of the available Parameters
- You can define, if one of those values should be splitted on two Modbus-Registers, making it a 32-bit Value
- For splitting a Value on two registers, you have to set the value of `"SecondReg"` to the `"VariableTag"` of the second register

Structure of UserInput.json:

  ```json
{
    "VariableTag": {
      "Register": "MB_RegNumber", (as string)
      "InitValue": int or 2-byte hex string
      "SecondReg": optional string for lower half of 32-bit values, has to be "VariableTag" of the second Register
      }
}
```

Available parameters from the SM:

```json
{
 "SMid": 0,
 "Pi": 0,
 "Po": 0,
 "P1i": 0,
 "P2i": 0,
 "P3i": 0,
 "P1o": 0,
 "P2o": 0,
 "P3o": 0,
 "V1": 0,
 "V2": 0,
 "V3": 0,
 "I1": 0,
 "I2": 0,
 "I3": 0,
 "Ei1": 0,
 "Ei2": 0,
 "Eo1": 0,
 "Eo2": 0 
}
```

#### Fixed Data

- You can implement Modbus-Registers, which are not updated by SM-Date but keep the `InitValue`
- For these you can create a self given `"VariableTag"`.
- The self given `"VariableTag"` shall not match one of the identifiers of the availabe Parameters
- For Fixed Data it is not allowed to add the property `"SecondReg"`

Example for fixed Data:

  ```json
{
  "VariableTag": {
    "Register": "MB_RegNumber", (as string)
    "InitValue": int (max 65535) or 2-byte hex-string
    }
}
```

#### Full example for UserInput.json

  ```json
{
  "SunSpec_ID_2": {
    "Register": "40002",
    "InitValue": "6E53"},
  
  "M_SunSpec_ID": {
    "Register": "40070",
    "InitValue": 201},

  "Ei": {
    "Register": "40116",
    "InitValue": "0000",
    "SecondReg": "Ei_2"},

  "Ei_2": {
    "Register": "40117",
    "InitValue": "0000"},
}
```

### ZZ_Playground

The repository includes a folder named [`ZZ_Playground`](ZZ_Playground), which contains useful example tools and presets for testing and experimenting with the system:

- **Register mapping presets** – Ready-to-use `UserInput.json` configurations
- **Python Modbus client** – A simple client script using [`pymodbusTCP`](https://pypi.org/project/pymodbusTCP/) to send requests and verify Modbus responses

## Credits

Special thanks to [wjohn007](https://github.com/wjohn007), whose implementation of a FSM in Berry Script has been reused for this project. Original repository: [https://github.com/wjohn007/Berry-Finit-State-Machine](https://github.com/wjohn007/Berry-Finit-State-Machine)
