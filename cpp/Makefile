# National Flag of Nepal

BASE    ?= 800
OUTDIR  ?= output

.PHONY: help build run all clean

help:
	@echo "build run all clean"

build:
	cmake -B build -DCMAKE_BUILD_TYPE=Release
	cmake --build build

run: build
	./build/flag-of-nepal $(BASE) $(OUTDIR)

all: run

clean:
	rm -rf build bin
	rm -rf $(OUTDIR)/*
	mkdir -p $(OUTDIR)
	touch $(OUTDIR)/.gitkeep
