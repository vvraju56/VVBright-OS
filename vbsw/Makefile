# Makefile for VVBright Subsystem for Windows (VBSW)

CC = gcc
CFLAGS = -Wall -Wextra -std=c11 -I./include
LDFLAGS = 
BUILD_DIR = ./build
SRC_DIR = ./src

all: $(BUILD_DIR)/main.exe

$(BUILD_DIR)/main.exe: $(SRC_DIR)/main.c
	$(CC) $(CFLAGS) $< -o $@ $(LDFLAGS)

clean:
	rm -f $(BUILD_DIR)/*.exe
	rm -f $(BUILD_DIR)/*.o

.PHONY: all clean