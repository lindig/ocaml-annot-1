# vim:ts=8 sw=4 noet:
#

TOP =	..

OCB =	ocamlbuild
LP =	$(TOP)/lipsum/lipsum

all:	tangle
	$(OCB) -libs str main.native 

clean:
	$(OCB) -clean
	for f in *.nw; do $(LP) roots $$f | xargs rm -f; done

tangle:
	for f in *.nw; do $(LP) expand -f cpp $$f; done


