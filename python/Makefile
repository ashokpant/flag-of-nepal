# National Flag of Nepal

UV      ?= uv
BASE    ?= 800
MODE    ?= color
FORMAT  ?= svg
OUTPUT  ?= output/np_flag_$(MODE)
OUTDIR  ?= output

.PHONY: help install sync flag html build run all upgrade clean

help:
	@echo "install sync flag html build run all upgrade clean"

install:
	$(UV) sync

sync: install

flag: install
	$(UV) run flag-of-nepal export \
		--base-length $(BASE) \
		--mode $(MODE) \
		--format svg \
		--output $(OUTPUT)

html: install
	$(UV) run flag-of-nepal export \
		--base-length $(BASE) \
		--format html \
		--output $(OUTDIR)/np_flag

build: install
	$(UV) run flag-of-nepal build \
		--base-length $(BASE) \
		--output-dir $(OUTDIR)

run: build

all: build

upgrade:
	$(UV) run flag-of-nepal upgrade

clean:
	rm -rf $(OUTDIR)/* dist/ build/
	rm -rf .venv src/flag_of_nepal/__pycache__
	rm -rf *.egg-info src/*.egg-info
	mkdir -p $(OUTDIR)
	touch $(OUTDIR)/.gitkeep
