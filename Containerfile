#
#
#
FROM scratch
MAINTAINER Mark Lamourine <mark@llamatek.dev>

ENV MAKEMKV_KEY=unset
ENV HOME=/
ENV LD_LIBRARY_PATH=/usr/lib:/usr/lib64

VOLUME /input
VOLUME /output

COPY build/model/ /
COPY build/resolved/ /
