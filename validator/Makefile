VERSION=2019-04
DISTNAME=regtapval-$(VERSION)

package:
	-mkdir $(DISTNAME)
	cp README runtests.py tests.json $(DISTNAME)
	-mkdir $(DISTNAME)/res
	cp res/* $(DISTNAME)/res
	tar -cvzf $(DISTNAME).tar.gz $(DISTNAME)
	rm -rf $(DISTNAME)


install:
	mkdir -p regtap-val
	cp -a *.tar.gz regtap-val/
	cp -a style.css regtap-val/
	rst2html --stylesheet=style.css README regtap-val/index.html
	rsync -av regtap-val alnilam:/var/www/docs/
	rm -rf regtap-val
