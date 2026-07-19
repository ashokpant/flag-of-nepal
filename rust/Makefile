# National Flag of Nepal

CARGO   ?= cargo
BASE    ?= 800
OUTDIR  ?= output

.PHONY: help build run all clean

help:
	@echo "build run all clean"

build:
	$(CARGO) build --release

run:
	$(CARGO) run --quiet -- $(BASE) $(OUTDIR)

all: run

clean:
	$(CARGO) clean
	rm -rf $(OUTDIR)/*
	mkdir -p $(OUTDIR)
	touch $(OUTDIR)/.gitkeep
