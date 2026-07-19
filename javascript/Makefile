NODE ?= node
BASE ?= 800
OUTDIR ?= output

.PHONY: run all clean help

help:
	@echo "  run        Generate flag SVGs + HTML into OUTDIR"
	@echo "  all        Alias for run"
	@echo "  clean      Remove generated files in OUTDIR"

run:
	$(NODE) flag-of-nepal.mjs $(BASE) $(OUTDIR)

all: run

clean:
	rm -rf $(OUTDIR)/* && touch $(OUTDIR)/.gitkeep
