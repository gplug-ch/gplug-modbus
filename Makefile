# Makefile to build a Tasmota .tapp file

# =============================================================================
# CONFIGURATION
# =============================================================================

VERSION := v$(shell cat VERSION.txt)
TARGET := gplug-modbus

# Base directories
ROOT_DIR := .

# Directory structure
BUILD_DIR := $(ROOT_DIR)/build
APP_DIR := $(ROOT_DIR)
TEST_DIR := $(ROOT_DIR)/tests

# Output files
TAPP := $(BUILD_DIR)/$(TARGET)-$(VERSION).tapp
ZIP := $(BUILD_DIR)/$(TARGET)-$(VERSION).zip

# Source files (exlude test files)
APP_SRC := $(shell ls *.be)
RES_SRC := $(shell ls *.json)

# Test files
TEST_SRC := $(shell cd $(TEST_DIR); ls test_*.be)

# =============================================================================
# MAIN TARGETS
# =============================================================================

.DEFAULT_GOAL := all
.PHONY: all tapp zip upload clean help

all: clean tapp

tapp: check-files | $(BUILD_DIR)
	@echo "Building TAPP file: $(TAPP)"
	@echo "Removing comments from source files..."
	@for file in $(APP_SRC) $(RES_SRC); do \
		sed '/^[[:space:]]*#/d; /^\s*\/\//d; s/\/\*.*\*\///g' "$$file" > "$(BUILD_DIR)/$$(basename "$$file")"; \
	done
	zip -0 -j $(TAPP) $(BUILD_DIR)/*
	@echo "TAPP file created successfully: $(TAPP)"

zip: $(ZIP_SRC) | $(BUILD_DIR)
	@echo "Creating ZIP archive: $(ZIP)"
	@echo "Including $(words $(ZIP_SRC)) source files..."
	@zip $(ZIP) README.md Makefile $(ZIP_SRC)

upload: tapp
	@echo "Uploading TAPP file to Tasmota device..."
	@$(call upload-tapp)
	@sleep 2  # sleep for 2 seconds, adjust as needed
	@$(call restart-berry)
	@echo "Upload and restart completed successfully"

test:
	@echo "Running tests... - $(TEST_SRC)"
	@for test_file in $(TEST_SRC); do \
		echo "Executing $$test_file..."; \
		(cd $(TEST_DIR) && berry -m .. $$test_file) || exit 1; \
	done
	@echo "All tests passed successfully"

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Upload function
define upload-tapp
	$(eval FILE_SIZE := $(shell wc -c < $(TAPP) 2>/dev/null || echo 0))
	curl --silent --show-error --form ufsu=@$(TAPP) "http://$(IP_TASMOTA_DEVICE)/ufsu?fsz=$(FILE_SIZE)" >/dev/null
	@exit_code=$$?; echo "Upload completed with exit code: $$exit_code"
endef

# Restart Berry VM function
define restart-berry
	curl --silent --show-error "http://$(IP_TASMOTA_DEVICE)/cs?c2=64&c1=brRestart" >/dev/null
	@exit_code=$$?; echo "Restart completed with exit code: $$exit_code"
endef

# =============================================================================
# MAINTENANCE TARGETS
# =============================================================================

.PHONY: clean check-file

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

clean:
	@echo "Cleaning build directory..."
	@rm -rf $(BUILD_DIR)
	@rm -rf $(CLIENT_DIR)/dist
	@echo "Build directory cleaned"

check-files:
	@if [ -f .env ]; then \
		echo "Found file '.env'"; \
	else \
		echo "No '.env' file found in current directory"; \
	fi
