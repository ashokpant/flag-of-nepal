# National Flag of Nepal

GO      ?= go
BASE    ?= 800
OUTDIR  ?= output

.PHONY: help build run all clean

help:
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

build:
	$(GO) build -o bin/flag-of-nepal .

run: ## Build flag SVGs + HTML into OUTDIR
	$(GO) run . $(BASE) $(OUTDIR)

all: run

clean: 
	rm -rf bin/
	rm -rf $(OUTDIR)/*
	touch $(OUTDIR)/.gitkeep
