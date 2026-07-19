# National Flag of Nepal

UV      ?= uv
BASE    ?= 800
MODE    ?= color
FORMAT  ?= svg
OUTPUT  ?= output/np_flag_$(MODE)
OUTDIR  ?= output

.PHONY: help install sync flag html build all upgrade clean

help:
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-12s %s\n", $$1, $$2}'

install:
	$(UV) sync

flag: install ## Export one SVG (BASE, MODE, OUTPUT)
	$(UV) run flag-of-nepal export \
		--base-length $(BASE) \
		--mode $(MODE) \
		--format svg \
		--output $(OUTPUT) \
		-v

html: install ## Export one HTML with all modes embedded
	$(UV) run flag-of-nepal export \
		--base-length $(BASE) \
		--format html \
		--output output/np_flag \
		-v

all: install ## Build all mode SVGs + multi-mode HTML
	$(UV) run flag-of-nepal build \
		--base-length $(BASE) \
		--output-dir $(OUTDIR) \
		-v

upgrade:
	$(UV) run flag-of-nepal upgrade -v

clean:
	rm -rf output/* dist/ build/
	rm -rf .venv __pycache__ src/flag_of_nepal/__pycache__
	rm -rf *.egg-info src/*.egg-info
	touch output/.gitkeep
