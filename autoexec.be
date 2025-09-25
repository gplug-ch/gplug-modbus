var required_modules = [
    "constants.be",
    "sunspec.be",
    "obiscode.be",
    "logger.be",
    "handlers.be",
    "middleware.be",
    "smartmeter.be",
    "clientsocket.be",
    "serversocket.be",
    "main.be"
]

# Load all modules and run the application
var working_dir = tasmota.wd  # Capture working directory at startup

print("Loading modules...")
var all_loaded = true
for module_name : required_modules
    if !load(working_dir + module_name)
        print("ERROR: Failed to load " + module_name)
        all_loaded = false
        break
    end
    print("- Loaded " + module_name)
end

# Try to load the sunspec definitions from the sunspec.json file
import sunspec
sunspec.load_registers(working_dir)
