CXX ?= g++
CXXFLAGS ?= -std=c++17 -O2
BASE ?= 800
OUTDIR ?= output

.PHONY: build run all clean help

build: bin/flag-of-nepal

bin/flag-of-nepal: main.cpp
	mkdir -p bin && $(CXX) $(CXXFLAGS) -o $@ main.cpp

run: build
	./bin/flag-of-nepal $(BASE) $(OUTDIR)

all: build run

clean:
	rm -rf bin

help:
	@echo "make build   — compile to bin/flag-of-nepal"
	@echo "make run     — build and write SVG/HTML to $(OUTDIR)/ (BASE=$(BASE))"
	@echo "make clean   — remove bin/"
