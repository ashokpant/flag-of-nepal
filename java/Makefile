# National Flag of Nepal

JAVAC   ?= javac
JAVA    ?= java
BASE    ?= 800
OUTDIR  ?= output
SRC     = src/main/java/flagofnepal/FlagOfNepal.java
OUT     = out

.PHONY: help build run all clean

help:
	@echo "build run all clean"

build: $(OUT)/flagofnepal/FlagOfNepal.class

$(OUT)/flagofnepal/FlagOfNepal.class: $(SRC)
	mkdir -p $(OUT) && $(JAVAC) -d $(OUT) $(SRC)

run: build
	$(JAVA) -cp $(OUT) flagofnepal.FlagOfNepal $(BASE) $(OUTDIR)

all: run

clean:
	rm -rf $(OUT) bin
	rm -f *.class
	rm -rf $(OUTDIR)/*
	touch $(OUTDIR)/.gitkeep
