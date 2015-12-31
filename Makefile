SOURCES_PROJECT=main.cpp # Add project source files here
PROJECT_NAME=main # result will be main.hex, then
PROGRAMMER=arduino # set your programmer here, I use the stk500. On the standard arduino isp it's "arduino"
PORT=/dev/tty.usbmodem1421 # set the port for the connection to your programmer here. Arduino sits at /dev/ttyACM0
MCU=atmega328p
CPU=16000000L 
AP_PATH=./
BAUDRATE=115200

ARDCOREDIR = /Applications/Arduino.app/Contents/Resources/Java/hardware/arduino/cores/arduino/
ARDVARIANTSDIR = $(ARDCOREDIR)../../variants/standard

CC=avr-gcc
CCP=avr-g++
AR=avr-ar rcs
OBJ=avr-objcopy
AVRDUDE=avrdude
ARFILE=$(ARDCOREDIR)core.a

AVRDUDEFLAGS=-c$(PROGRAMMER) -p$(MCU) -P$(PORT) -b$(BAUDRATE)
EEPFLAGS=-O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0
HEXFLAGS=-O ihex -R .eeprom
CFLAGS=-c -g -Os -Wall -fno-exceptions -ffunction-sections -fdata-sections -mmcu=$(MCU) -DF_CPU=$(CPU) -MMD -DUSB_VID=null -DUSB_PID=null -DARDUINO=101 -I$(ARDCOREDIR) -I$(ARDVARIANTSDIR)
LDFLAGS=-Os -Wl,--gc-sections -mmcu=$(MCU) -L$(ARDCOREDIR)-L$(AP_PATH) -lm
OBJECTS_PROJECT=$(SOURCES_PROJECT:.cpp=.o)
SOURCES_ARDUINO_C=$(ARDCOREDIR)wiring_digital.c $(ARDCOREDIR)WInterrupts.c $(ARDCOREDIR)wiring_pulse.c $(ARDCOREDIR)wiring_analog.c $(ARDCOREDIR)wiring.c $(ARDCOREDIR)wiring_shift.c
OBJECTS_ARDUINO_C=$(SOURCES_ARDUINO_C:.c=.o)
SOURCES_ARDUINO_CPP=$(ARDCOREDIR)CDC.cpp $(ARDCOREDIR)Stream.cpp $(ARDCOREDIR)HID.cpp $(ARDCOREDIR)Tone.cpp $(ARDCOREDIR)WMath.cpp $(ARDCOREDIR)WString.cpp $(ARDCOREDIR)new.cpp $(ARDCOREDIR)main.cpp $(ARDCOREDIR)HardwareSerial.cpp $(ARDCOREDIR)IPAddress.cpp $(ARDCOREDIR)Print.cpp $(ARDCOREDIR)USBCore.cpp
OBJECTS_ARDUINO_CPP=$(SOURCES_ARDUINO_CPP:.cpp=.o)
OBJECTS=$(OBJECTS_PROJECT) $(OBJECTS_ARDUINO_C) $(OBJECTS_ARDUINO_CPP)
OBJECTS_CORE=$(OBJECTS_ARDUINO_C) $(OBJECTS_ARDUINO_CPP)
ELFCODE=$(join $(PROJECT_NAME),.elf)
EEPCODE=$(join $(PROJECT_NAME),.eep)
HEXCODE=$(join $(PROJECT_NAME),.hex)

all: clean $(SOURCES) $(ARFILE) $(ELFCODE) $(EEPCODE) $(HEXCODE)

$(ARFILE): $(OBJECTS)
	$(AR) $(ARFILE) $(OBJECTS)

.cpp.o:
	$(CC) $(CFLAGS) $< -o $@

$(ELFCODE):
	$(CC) $(LDFLAGS) $(OBJECTS_PROJECT) $(ARFILE) -o $@

$(EEPCODE):
	$(OBJ) $(EEPFLAGS) $(ELFCODE) $@

$(HEXCODE):
	$(OBJ) $(HEXFLAGS) $(ELFCODE) $@

clean_obj:
	rm -rf $(OBJECTS) $(ARFILE)

clean_results:
	rm -rf $(ELFCODE) $(EEPCODE) $(HEXCODE)

clean: clean_obj clean_results

upload:
	$(AVRDUDE) $(AVRDUDEFLAGS) -Uflash:w:$(HEXCODE):i
