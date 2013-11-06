#
# 
#

PREFIX =    $(HOME)
BINDIR =    $(HOME)/bin
MAN1DIR =   $(HOME)/man/man1

all:	lipsum
	$(MAKE) -C src $@

clean:
	$(MAKE) -C src    $@
	$(MAKE) -C lipsum $@

install: all
	install src/_build/main.native $(BINDIR)/annot
	install src/annot.1 $(MAN1DIR)

lipsum: FORCE
	$(MAKE) -C lipsum all

FORCE:

