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
COPY scripts/entrypoint.sh /usr/bin/entrypoint

CMD info /input

#ENTRYPOINT ["/usr/bin/makemkvcon"]
ENTRYPOINT ["/usr/bin/entrypoint"]
