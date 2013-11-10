#
# 
#

PREFIX =    $(HOME)
BINDIR =    $(HOME)/bin
MAN1DIR =   $(HOME)/man/man1
LIPSUM =    https://github.com/lindig/lipsum.git

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

# update lipsum subtree from upstream
update:
	git subtree pull --prefix lipsum $(LIPSUM) master --squash
	

FORCE:

