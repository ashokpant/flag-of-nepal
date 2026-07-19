# National Flag of Nepal

JAVAC   ?= javac
JAVA    ?= java
BASE    ?= 800
OUTDIR  ?= output
SRC     = FlagOfNepal.java
CLASS   = FlagOfNepal.class

.PHONY: help build run all clean

help:
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

build: $(CLASS) # Compile FlagOfNepal.java

$(CLASS): $(SRC)
	$(JAVAC) $(SRC)

run: build # Build flag SVGs + HTML into OUTDIR
	$(JAVA) FlagOfNepal $(BASE) $(OUTDIR)

all: run

clean:
	rm -f *.class
	rm -rf $(OUTDIR)/*
	touch $(OUTDIR)/.gitkeep
