# National Flag of Nepal

GO      ?= go
BASE    ?= 800
OUTDIR  ?= output

.PHONY: help build run all clean

help:
	@echo "build run all clean"

build:
	mkdir -p bin
	$(GO) build -o bin/flag-of-nepal ./cmd/flag-of-nepal

run:
	$(GO) run ./cmd/flag-of-nepal $(BASE) $(OUTDIR)

all: run

clean:
	rm -rf bin/
	rm -rf $(OUTDIR)/*
	mkdir -p $(OUTDIR)
	touch $(OUTDIR)/.gitkeep
