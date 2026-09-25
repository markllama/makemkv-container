#!/usr/bin/make -f


clean-build:
	rm -rf build/makemkv* build/model

clean-ffmpeg:
	rm -rf build/usr build/ffmpeg

clean-model:
	rm -rf build/model

clean-all:
	rm -rf build/*
	find * -type f -name \*~ | xargs -I{} rm {}
