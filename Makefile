PREFIX=$(HOME)

.PHONY: all install clean

all: imp3s imp3c

install: imp3s imp3c
	install imp3c imp3s $(PREFIX)/bin
	install -m 644 imp3.py $(PREFIX)/bin

uninstall:
	rm $(PREFIX)/bin/{imp3c,imp3s,imp3.py}

imp3.py: imp3.g
	yapps2 imp3.g

imp3c: imp3.py

clean:
	rm -f imp3.py
