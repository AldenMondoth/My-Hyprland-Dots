CXX      := g++
CXXFLAGS := -std=c++17 -O2 -Wall
LDFLAGS  := -lcurl
TARGET   := Weather
SRC      := Weather.cpp

.PHONY: all clean install deps

all: $(TARGET)

$(TARGET): $(SRC)
	$(CXX) $(CXXFLAGS) -o $@ $< $(LDFLAGS)

# Install build dependencies (Debian/Ubuntu)
deps:
	sudo apt install -y libcurl4-openssl-dev nlohmann-json3-dev

clean:
	rm -f $(TARGET)

# Optional: copy binary next to the scripts
install: $(TARGET)
	cp $(TARGET) $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
