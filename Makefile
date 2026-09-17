#!/usr/bin/make -f

all:
	@echo Do nothing unless specifically asked: clean

clean:
	rm -rf build usr model rpms unpack
