#
# 
#

PREFIX =    $(HOME)
BINDIR =    $(HOME)/bin
MAN1DIR =   $(HOME)/man/man1

all:	lipsum
	$(MAKE) -C src $@

clean:
	$(MAKE) -C src $@

install: all


lipsum: FORCE
	$(MAKE) -C lipsum all

FORCE:

