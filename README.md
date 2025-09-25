# gplug‑modbus

A lightweight Modbus-TCP server implementation for [gPlug](https://gplug.ch/) running on ESP32-C3 with Tasmota firmware, providing flexible user-configurable register mappings to serve SmartMeter and SunSpec protocol data efficiently.

## Table of Contents

1. [Overview](#overview)  
2. [Features](#features)  
3. [Architecture & Concepts](#architecture--concepts)  
4. [Prerequisites](#prerequisites)  
5. [Installation](#installation)  
6. [Usage / Example](#usage--example)  
7. [Configuration](#configuration)  
8. [Building from Source](#building-from-source)  
9. [Limitations & Future Work](#limitations--future-work)  
10. [License](#license)  
11. [References](#references)  

## Overview

This project implements a **lightweight Modbus‑TCP server** in Berry Script (inside Tasmota) running on a gPlug device (ESP32‑C3). It allows exposing SmartMeter or SunSpec data via Modbus, with flexible register mapping defined by the user.  

Typical use case: you have a gPlug running Tasmota + Berry support, and want to read meter / inverter / device data from it via Modbus (for systems like SCADA, home automation, etc.).

## Features

- Implements Modbus TCP, **function code 3 (Read Holding Registers)**  
- Runs entirely within Berry Script / Tasmota on the gPlug — no external hardware  
- User‑definable mapping (via `user‑mapping.json`) to adapt to:
  - Proprietary registers from your SmartMeter or device  
  - Standard SunSpec / device information models  
- Lightweight, efficient, easily extendable  

## Architecture & Concepts

- **gPlug + Tasmota + Berry VM**  
  The server is a Berry script executed inside Tasmota’s Berry VM.  
- **Modbus model**  
  Only function code 3 (read holding registers) is supported for now.  
- **Mapping layer**  
  The `user-mapping.json` file lets you map internal data / sensor values to Modbus register ranges.  
- **Data source (SmartMeter / SunSpec devices)**  
  The script reads local meter / inverter data (through Tasmota sensors, HTTP, or other built-in capabilities) and exposes them over Modbus as needed.

## Prerequisites

- gPlug device running Tasmota (version ≥ 14.5.0) with Berry scripting enabled  
- A SmartMeter (or inverter, sensor, etc.) from which you can read data (e.g. via MQTT / HTTP / sensor interfaces)  
- Some familiarity with Modbus, register mapping, and JSON configuration  

## Installation

1. **Upload `.tapp` file**  
   Use Tasmota’s web UI or other interfaces (HTTP, MQTT, etc.) to upload the compressed `.tapp` file.

2. **Restart Berry VM**  
   After uploading, run `brrestart` from the Tasmota console to load the script.

3. **Place mapping file**  
   Add your `user‑mapping.json` (copied/modified from the template) into the correct directory so that the script can load it.

## Usage / Example

You can test using a Modbus client, e.g. [`mbpoll`](https://github.com/epsilonrt/mbpoll).  

```bash
mbpoll -v -t 4 -1 -0 -p 502 -a 201 -r 40070 -c 59 gplugk.local |   { while read R; do echo "$(date +%T\ %N) $R"; done }
```

This reads 59 holding registers starting at address 40070 from unit ID 201 on port 502 of `gplugk.local`.  
(Adapt the addresses, count, unit ID, etc. based on your mapping and environment.)

## Configuration

This JSON file defines which internal data values map to which Modbus registers (addresses, types, scaling, etc.).  

You should base your mapping on either:

- Your device’s proprietary registers / data points  
- The **SunSpec Device Information Model**, if compatible  

Include details like:

- Modbus **address** / offset  
- Data **type** (e.g. unsigned, signed, float, etc.)  
- **Scaling** or units  
- **Description** / label  

> **Note:** If no user‑specific mapping file is provided, the default [`sunspec.json`](./sunspec.json) will be used.

## Building from Source

If you want to build your own `.tapp`:

```bash
# Requirements: GNU Make (v4.3+), Berry scripting sources
make
```

This produces the deployable `.tapp` file you can upload onto your gPlug.

## Limitations & Future Work

- Currently only supports **Modbus function code 3** (read holding registers)  
- No support for writing registers (function codes 6, 16, etc.)  
- No automatic register discovery – user must configure mapping manually  
- Error handling and diagnostics could be improved  
- Expansion ideas:
  - Support for more Modbus function codes  
  - Auto-generate mapping from device metadata  
  - Support multiple slave unit IDs  
  - Integration with MQTT bridging  

## License

This project is licensed under **Apache‑2.0**. You may use, modify, and distribute under the terms of that license.  

## References

- [MODBUS Application Protocol Specification V1.1b3 (for protocol reference)](https://www.afs.enea.it/project/protosphera/Proto-Sphera_Full_Documents/mpdocs/docs_EEI/Modbus_Application_Protocol_V1_1b3.pdf)
- [SunSpec Device Information Model Specification (for standard register mapping)](https://sunspec.org/wp-content/uploads/2025/01/SunSpec-Device-Information-Model-Specificiation-V1-2-1-1.pdf)
- [Berry Scripting Language](https://berry-lang.github.io/)
- [Tasmota documentation](https://tasmota.github.io/docs/)
- (for testing) [mbpoll](https://github.com/epsilonrt/mbpoll)
