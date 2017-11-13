##
##  This file is part of CM-Makefile.
##
##  Copyright (C) 2015 Adam Heinrich <adam@adamh.cz>
##
##  CM-Makefile is free software: you can redistribute it and/or modify
##  it under the terms of the GNU Lesser General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  CM-Makefile is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU Lesser General Public License for more details.
##
##  You should have received a copy of the GNU Lesser General Public License
##  along with CM-Makefile.  If not, see <http://www.gnu.org/licenses/>.
##

# OpenOCD target configuration
OPENOCD ?= openocd -f board/st_nucleo_f0.cfg

HELP_TEXT += \n\
  flash - Flash using OpenOCD\n\
  reset - Reset the target MCU using OpenOCD\n\
  gdb - Start OpenOCD as GDB server\n\
  debug - Start debugger and connect to the GDB server

.PHONY: flash
flash: $(BUILD_DIR)/$(BIN).hex
	$(CMD_ECHO) $(OPENOCD) -c \
	"init; \
	reset halt; \
	sleep 100; \
	flash write_image erase $^; \
	reset run; \
	shutdown"

.PHONY: reset
reset:
	$(CMD_ECHO) $(OPENOCD) -c \
	"init; \
	reset halt; \
	sleep 100; \
	reset run; \
	shutdown"

.PHONY: gdb
gdb: $(BUILD_DIR)/$(BIN).hex
	$(CMD_ECHO) $(OPENOCD) -c \
	"init; \
	reset halt; \
	sleep 100; \
	flash write_image erase $^; \
	reset halt"

.PHONY: debug
debug: $(BUILD_DIR)/$(BIN).elf
	@echo "Starting cdtdebug with $(GDB)..."
	$(CMD_ECHO) echo "org.eclipse.cdt.dsf.gdb/defaultGdbCommand=$(GDB)" \
	    > $(BUILD_DIR)/cdtdebug.ini
	$(CMD_ECHO) $(CDTDEBUG) -pluginCustomization $(BUILD_DIR)/cdtdebug.ini \
	    -r localhost:3333 -e $(realpath $^) &
