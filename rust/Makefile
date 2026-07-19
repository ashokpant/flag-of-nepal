# National Flag of Nepal (Rust)

CARGO   ?= cargo
BASE    ?= 800
OUTDIR  ?= output

.PHONY: help build run all clean

help:
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

build:
	$(CARGO) build --release

run: ## Build flag SVGs + HTML into OUTDIR
	$(CARGO) run --quiet -- $(BASE) $(OUTDIR)

all: run

clean:
	$(CARGO) clean
	rm -rf $(OUTDIR)/*
	mkdir -p $(OUTDIR)
	touch $(OUTDIR)/.gitkeep
