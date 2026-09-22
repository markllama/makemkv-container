#!/usr/bin/make -f

clean:
	rm -rf build usr model TARBALLS src
	find * -type f -name \*~ | xargs -I{} rm {}
