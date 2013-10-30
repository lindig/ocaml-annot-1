# vim:ts=8 sw=4 noet:
#

.PHONY: all byte src clean

TOP =	..

SRC =	annot.ml	\
	annot.mli	\
	intervalmap.ml	\
	intervalmap.mli \
	main.ml		\
	main.mli	\
	position.ml	\
	position.mli	\
	parser.mly	\
	scanner.mli	\
	scanner.mll	\


OCB =	ocamlbuild
LP =	$(TOP)/lipsum/lipsum

all:	$(SRC)
	$(OCB) -libs str main.native 
	cp main.native annot

byte:   $(SRC)
	$(OCB) -libs str main.byte

src:	$(SRC)

clean:
	$(OCB) -clean
	for f in *.nw; do $(LP) roots $$f | xargs rm -f; done
	rm -f annot main.byte main.native

%.ml:		%.nw
		$(LP) tangle -f cpp $@ $< >$@

%.mli:		%.nw
		$(LP) tangle -f cpp $@ $< >$@

scanner.mll:	syntax.nw
		$(LP) tangle -f cpp $@ $< >$@

scanner.mli:	syntax.nw
		$(LP) tangle -f cpp $@ $< >$@

parser.mly:	syntax.nw
		$(LP) tangle -f cpp $@ $< >$@

