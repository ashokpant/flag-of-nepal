# National Flag of Nepal

NODE    ?= node
BASE    ?= 800
OUTDIR  ?= output

.PHONY: help build run all clean

help:
	@echo "build run all clean"

build:
	@:

run:
	$(NODE) bin/flag-of-nepal.mjs $(BASE) $(OUTDIR)

all: run

clean:
	rm -rf $(OUTDIR)/*
	mkdir -p $(OUTDIR)
	touch $(OUTDIR)/.gitkeep
